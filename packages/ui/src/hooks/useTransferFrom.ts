import { useMemo, useState } from "react";
import {
  useContract,
  useProvider,
  useSendTransaction,
} from "@starknet-react/core";
import {
  MERKLE_TREE_DEPTH,
  PRIVATE_ERC20_ABI,
  PRIVATE_ERC20_CONTRACT_ADDRESS,
  PRIVATE_ERC20_DEPLOY_BLOCK,
  PRIVATE_ERC20_EVENT_KEY,
} from "@/shared/config/constants";
import { ApprovalEvent, ApprovalPayload, Note } from "@/interfaces";
import { ProofService } from "@/services/proof.service";
import { Fr } from "@aztec/bb.js";
import { AccountService } from "@/services/account.service";
import { BarretenbergService } from "@/services/bb.service";
import { formatHex, parse } from "@/lib/utils";
import { MerkleTree } from "@/lib/merkle-tree";
import { NotesService } from "@/services/notes.service";
import { hash, num, events as Events, CallData, Provider } from "starknet";
// import { provider } from "@/shared/config/rpc";
import { CipherService } from "@/services/cipher.service";

export const useTransferFrom = () => {
  const { provider } = useProvider() as { provider: Provider };
  const [loading, setLoading] = useState(false);

  const { contract } = useContract({
    abi: PRIVATE_ERC20_ABI,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const { sendAsync } = useSendTransaction({
    calls: undefined,
  });

  const notesService = useMemo(() => {
    return new NotesService(provider);
  }, [provider]);

  const sendTransferFrom = async (props: {
    from: { address: bigint; publicKey: bigint };
    to: { address: bigint; publicKey: bigint };
    amount: bigint;
  }) => {
    setLoading(true);

    try {
      if (!contract) {
        throw new Error("Contract not initialized");
      }

      const spenderAccount = await AccountService.getAccount();

      // TODO: retrieve notes that are approved
      const lastBlock = await provider.getBlock("latest");

      // TODO:
      const relationshipId = await BarretenbergService.generateHashArray([
        new Fr(props.from.address),
        new Fr(spenderAccount.address),
      ]);
      // 0x280c2a33f20f560f449b16a1ff045707c687269a12bce3315dbb942da45b43e0
      const keyFilter = [[num.toHex(hash.starknetKeccak("Approval"))]];

      let continuationToken = undefined;
      const approvalEvents: ApprovalEvent[] = [];
      do {
        const res = await provider.getEvents({
          address: PRIVATE_ERC20_CONTRACT_ADDRESS,
          from_block: { block_number: PRIVATE_ERC20_DEPLOY_BLOCK }, // TODO: avoid fetching
          to_block: { block_number: lastBlock.block_number },
          keys: keyFilter,
          chunk_size: 10,
          continuation_token: continuationToken,
        });

        const parsed = Events.parseEvents(
          res.events,
          Events.getAbiEvents(PRIVATE_ERC20_ABI),
          CallData.getAbiStruct(PRIVATE_ERC20_ABI),
          CallData.getAbiEnum(PRIVATE_ERC20_ABI)
        );
        console.log("parsed", parsed);

        const sortedApprovalEvents = parsed
          .filter((event) => event[PRIVATE_ERC20_EVENT_KEY])
          .map((event) => event[PRIVATE_ERC20_EVENT_KEY])
          .map((event) => ({
            allowance_hash: event.allowance_hash,
            allowance_relationship: event.allowance_relationship,
            output_enc_owner: event.output_enc_owner,
            output_enc_spender: event.output_enc_spender,
            timestamp: event.timestamp,
          })) as ApprovalEvent[];

        approvalEvents.push(...sortedApprovalEvents);

        continuationToken = res.continuation_token;
      } while (continuationToken);

      console.log("approval", approvalEvents);

      const approval = approvalEvents
          .sort((a, b) => Number(b.timestamp) - Number(a.timestamp))[0];

      console.log("last Approval", approval);

      const allowance: ApprovalPayload = parse(
        await CipherService.decrypt(
          approval.output_enc_spender,
          spenderAccount.publicKey,
          spenderAccount.privateKey
        )
      );
      console.log("allowance", allowance);

      // check if spender has enough allowance
      if (allowance.allowance < props.amount) {
        throw new Error("Insufficient allowance");
      }

      // fetch all notes
      const { notesArray, notesMap } = await notesService.getNotes();
      
      // filter already spent notes
      const spendableNotes = allowance.commitments.filter((c) => {
        const note = notesMap.get(c.commitment);
        return note && !note.spent;
      });

      // select note to use for transfer
      const inputNote = spendableNotes
        .sort((a, b) => parseInt((b.value! - a.value!).toString()))
        .find((n) => n.value! > props.amount);
      if (!inputNote) {
        throw new Error("Insufficient funds in notes");
      }

      const inputCommitmentTracker = await BarretenbergService.generateHashArray([
        new Fr(inputNote.commitment % Fr.MODULUS),
        new Fr(inputNote.bliding % Fr.MODULUS),
      ])
  

      // generate proof
      const outOwnerAmount = inputNote.value! - props.amount;

      // rebuild tree
      const tree = new MerkleTree();
      const orderedNotes = notesArray.sort((a, b) =>
        parseInt((a.index! - b.index!).toString())
      );
      for (const note of orderedNotes) {
        await tree.addCommitment(note.commitment);
      }

      // compute input commitment root and path
      const inRoot = tree.getRoot();
      const inputCommitmentProof = tree.getProof(inputNote.commitment);
      if (!inputCommitmentProof) {
        throw new Error("Input commitment doesn't belong to the tree");
      }

      // generate notes
      const [outOwnerNote, outReceiverNote] = await Promise.all([
        BarretenbergService.generateNote(
          props.from.address,
          props.from.publicKey,
          outOwnerAmount
        ),
        BarretenbergService.generateNote(
          props.to.address,
          props.to.publicKey,
          props.amount
        ),
      ]);
      await tree.addCommitment(outOwnerNote.commitment);
      await tree.addCommitment(outReceiverNote.commitment);

      const outRoot = tree.getRoot();
      const outPathProof = tree.getProof(outOwnerNote.commitment);

      const inAllowanceHash = await BarretenbergService.generateHashArray([
        new Fr(props.from.address),
        new Fr(spenderAccount.address),
        new Fr(allowance.allowance),
      ]);

      const outAllowanceHash = await BarretenbergService.generateHashArray([
        new Fr(props.from.address),
        new Fr(spenderAccount.address),
        new Fr(allowance.allowance - props.amount),
      ]);

      const generatedProof = await ProofService.generateTransferFromProof({
        // account details
        owner_account: formatHex(props.from.address),
        receiver_account: formatHex(props.to.address),
        spender_private_key: formatHex(spenderAccount.privateKey % Fr.MODULUS),
        // input commitment details
        in_commitment_root: formatHex(inRoot),
        in_commitment_path: inputCommitmentProof.path.map((e) => formatHex(e)),
        in_commitment_direction_selector:
          inputCommitmentProof.directionSelector,
        in_commitment_bliding: formatHex(inputNote.bliding!),
        in_commitment_value: formatHex(inputNote.value!),
        in_commitment_spending_tracker: formatHex(inputCommitmentTracker),
        
        
        in_allowance_value: formatHex(allowance.allowance),
        in_allowance_hash: formatHex(inAllowanceHash), 
        in_allowance_relationship: formatHex(relationshipId),

        
        out_allowance_hash: formatHex(outAllowanceHash),
        out_receiver_value: formatHex(outReceiverNote.value),
        out_receiver_bliding: formatHex(outReceiverNote.bliding),
        out_receiver_commitment: formatHex(outReceiverNote.commitment),
        
        out_owner_value: formatHex(outOwnerNote.value),
        out_owner_bliding: formatHex(outOwnerNote.bliding),
        out_owner_commitment: formatHex(outOwnerNote.commitment),

        out_root: formatHex(outRoot),
        out_subtree_root_path: outPathProof.path
          .slice(1, MERKLE_TREE_DEPTH)
          .map((e) => formatHex(e)),
        out_subtree_direction_selector: outPathProof.directionSelector.slice(
          1,
          MERKLE_TREE_DEPTH
        ),
      });

      const callData = contract.populate("transfer_from", [
        generatedProof,
        outOwnerNote.encOutput, 
        outReceiverNote.encOutput,
      ]);

      await sendAsync([callData]);
    } catch (error) {
      console.error("Error in transferFrom:", error);
    } finally {
      setLoading(false);
    }
  };

  return { sendTransferFrom, loading };
};
