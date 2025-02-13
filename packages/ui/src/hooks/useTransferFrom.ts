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
import { ApprovalEvent, Note } from "@/interfaces";
import { ProofService } from "@/services/proof.service";
import { Fr } from "@aztec/bb.js";
import { AccountService } from "@/services/account.service";
import { BarretenbergService } from "@/services/bb.service";
import { formatHex } from "@/lib/utils";
import { MerkleTree } from "@/lib/merkle-tree";
import { NotesService } from "@/services/notes.service";
import { hash, num, events as Events, CallData } from "starknet";
import { provider } from "@/shared/config/rpc";
import { CipherService } from "@/services/cipher.service";

export const useTransferFrom = () => {
  // const { provider } = useProvider() as { provider: Provider };
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
      const relationshipId = await BarretenbergService.generateHashArray([
        new Fr(
          BigInt(
            "0xf4280fa36dd274233822111013be2d770e02332ac2766ae093aa25ee33a2d31" // approver
          )
        ),
        new Fr(
          BigInt(
            "0x1157bc9404765dd3c073c4ad1593445c1e96e6d1504a12d6b53d38f26e8c99eb" // spender
          )
        ),
      ]);
      const keyFilter = [
        [num.toHex(hash.starknetKeccak("Approval")), num.toHex(relationshipId)],
      ];

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

        const sortedApprovalEvents = parsed
          .filter((event) => event[PRIVATE_ERC20_EVENT_KEY])
          .map((event) => event[PRIVATE_ERC20_EVENT_KEY])
          .map((event) => ({
            allowance_hash: event.allowance_hash,
            allowance_relationship: event.allowance_relationship,
            output_enc: event.output_enc,
            timestamp: event.timestamp,
          })) as ApprovalEvent[];

        approvalEvents.push(...sortedApprovalEvents);

        continuationToken = res.continuation_token;
      } while (continuationToken);

      console.log("approval", approvalEvents);

      const approval = approvalEvents.sort((a, b) =>
        Number(a.timestamp - b.timestamp)
      )[0];
      console.log("last Approval", approval);

      const dec = await CipherService.decrypt(
        approval.output_enc,
        BigInt(
          "0x2caa6f22dd2b39742da00ce519c8ada57ad5d507dc99fdf6060d02c47f136648"
        ),
        BigInt(
          "0x2efe4d50e62d08f1335a7d8b6e8cb0a1b92d68e9bc34fcab1f547b2588d36ff1"
        )
      );
      console.log("dec", dec);

      // select note to use for transfer
      // const notes = [] as Note[]; // TODO: get approved notes
      // const senderNotes = notes.filter((n) => n.value !== undefined);
      // const inputNote = senderNotes
      //   .sort((a, b) => parseInt((b.value! - a.value!).toString()))
      //   .find((n) => n.value! > props.amount);
      // if (!inputNote) {
      //   throw new Error("Insufficient funds in notes");
      // }

      // generate proof
      // const outSenderAmount = inputNote.value! - props.amount;
      // const callerAccount = await AccountService.getAccount();

      // // rebuild tree
      // const tree = new MerkleTree();
      // const notes = await notesService.getNotes();
      // const orderedNotes = notes.sort((a, b) =>
      //   parseInt((a.index! - b.index!).toString())
      // );
      // for (const note of orderedNotes) {
      //   await tree.addCommitment(note.commitment);
      // }

      // // compute input commitment root and path
      // const inRoot = tree.getRoot();
      // const inputCommitmentProof = tree.getProof(inputNote.commitment);
      // if (!inputCommitmentProof) {
      //   throw new Error("Input commitment doesn't belong to the tree");
      // }

      // // generate notes
      // const [outSenderNote, outReceiverNote] = await Promise.all([
      //   BarretenbergService.generateNote(
      //     callerAccount.address,
      //     callerAccount.publicKey,
      //     outSenderAmount
      //   ),
      //   BarretenbergService.generateNote(
      //     props.to.address,
      //     props.to.publicKey,
      //     props.amount
      //   ),
      // ]);
      // await tree.addCommitment(outSenderNote.commitment);
      // await tree.addCommitment(outReceiverNote.commitment);

      // const outRoot = tree.getRoot();
      // const outPathProof = tree.getProof(outSenderNote.commitment);

      // const generatedProof = await ProofService.generateTransferFromProof({
      //   // account details
      //   owner_account: formatHex(props.from.address),
      //   receiver_account: formatHex(props.to.address),
      //   spender_private_key: formatHex(callerAccount.privateKey % Fr.MODULUS),
      //   // input commitment details
      //   in_commitment_root: formatHex(inRoot),
      //   in_commitment_path: inputCommitmentProof.path.map((e) => formatHex(e)),
      //   in_commitment_direction_selector:
      //     inputCommitmentProof.directionSelector,
      //   in_commitment_bliding: formatHex(inputNote.bliding!),
      //   in_commitment_value: formatHex(inputNote.value!),
      //   in_commitment_spending_tracker: formatHex(inputNote.value!),
      //   in_allowance_value: formatHex(inputNote.value!),
      //   in_allowance_hash: formatHex(inputNote.value!),
      //   in_allowance_relationship: formatHex(inputNote.value!),

      //   out_allowance_hash: formatHex(outReceiverNote.bliding),
      //   out_receiver_value: formatHex(outSenderAmount),
      //   out_receiver_bliding: formatHex(outReceiverNote.bliding),
      //   out_receiver_commitment: formatHex(outReceiverNote.commitment),
      //   out_owner_value: formatHex(outRoot),
      //   out_owner_bliding: formatHex(outRoot),
      //   out_owner_commitment: formatHex(outRoot),
      //   out_root: formatHex(outRoot),
      //   out_subtree_root_path: outPathProof.path
      //     .slice(1, MERKLE_TREE_DEPTH)
      //     .map((e) => formatHex(e)),
      //   out_subtree_direction_selector: outPathProof.directionSelector.slice(
      //     1,
      //     MERKLE_TREE_DEPTH
      //   ),
      // });

      // const callData = contract.populate("transfer_from", [
      //   generatedProof,
      //   outSenderNote.encOutput, // TODO: should include ourselves here
      //   outReceiverNote.encOutput,
      // ]);

      // await sendAsync([callData]);
    } catch (error) {
      console.error("Error in transferFrom:", error);
    } finally {
      setLoading(false);
    }
  };

  return { sendTransferFrom, loading };
};
