import { useState } from "react";
import { useContract, useSendTransaction } from "@starknet-react/core";
import {
  MERKLE_TREE_DEPTH,
  PRIVATE_ERC20_ABI,
  PRIVATE_ERC20_CONTRACT_ADDRESS,
  PRIVATE_ERC20_DEPLOY_BLOCK,
  PRIVATE_ERC20_EVENT_KEY,
} from "@/shared/config/constants";
import {
  ApprovalEvent,
  ApprovalPayload,
  CommitmentPayload,
} from "@/interfaces";
import { ProofService } from "@/services/proof.service";
import { Fr } from "@aztec/bb.js";
import { AccountService } from "@/services/account.service";
import { BarretenbergService } from "@/services/bb.service";
import { formatHex, parse } from "@/lib/utils";
import { MerkleTree } from "@/lib/merkle-tree";
import { notesService } from "@/services/notes.service";
import { hash, num, events as Events, CallData } from "starknet";
import { CipherService } from "@/services/cipher.service";
import { provider } from "@/shared/config/rpc";
import { DefinitionsService } from "@/services/definitions.service";

export const useTransferFrom = () => {
  const [loading, setLoading] = useState(false);

  const { contract } = useContract({
    abi: PRIVATE_ERC20_ABI,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const { sendAsync } = useSendTransaction({
    calls: undefined,
  });

  const sendTransferFrom = async (props: {
    from: { address: bigint; publicKey: bigint };
    to: { address: bigint; publicKey: bigint };
    amount: bigint;
  }): Promise<string> => {
    setLoading(true);

    try {
      if (!contract) {
        throw new Error("Contract not initialized");
      }

      const spenderAccount = await AccountService.getAccount();

      let continuationToken = undefined;
      const approvalEvents: ApprovalEvent[] = [];
      const lastBlock = await provider.getBlock("latest");

      // TODO: query all this with indexer instead
      do {
        const res = await provider.getEvents({
          address: PRIVATE_ERC20_CONTRACT_ADDRESS,
          from_block: { block_number: PRIVATE_ERC20_DEPLOY_BLOCK }, // TODO: avoid fetching all
          to_block: { block_number: lastBlock.block_number },
          keys: [[num.toHex(hash.starknetKeccak("Approval"))]],
          chunk_size: 10,
          continuation_token: continuationToken,
        });

        const parsed = Events.parseEvents(
          res.events,
          Events.getAbiEvents(PRIVATE_ERC20_ABI),
          CallData.getAbiStruct(PRIVATE_ERC20_ABI),
          CallData.getAbiEnum(PRIVATE_ERC20_ABI)
        );

        const sortedApprovalEvents = parsed.reduce((acc, event) => {
          if (event[PRIVATE_ERC20_EVENT_KEY]) {
            console.log("event", event[PRIVATE_ERC20_EVENT_KEY]);
            acc.push({
              allowance_hash: event[PRIVATE_ERC20_EVENT_KEY]
                .allowance_hash as bigint,
              allowance_relationship: event[PRIVATE_ERC20_EVENT_KEY]
                .allowance_relationship as bigint,
              output_enc_owner: event[PRIVATE_ERC20_EVENT_KEY]
                .output_enc_owner as string,
              output_enc_spender: event[PRIVATE_ERC20_EVENT_KEY]
                .output_enc_spender as string,
              timestamp: event[PRIVATE_ERC20_EVENT_KEY].timestamp as bigint,
            });
          }
          return acc;
        }, [] as ApprovalEvent[]);

        approvalEvents.push(...sortedApprovalEvents);

        continuationToken = res.continuation_token;
      } while (continuationToken);

      const relationshipId = await BarretenbergService.generateHashArray([
        new Fr(props.from.address % Fr.MODULUS),
        new Fr(spenderAccount.owner.address % Fr.MODULUS),
      ]);

      console.log("approvalEvents", approvalEvents);
      const approval = approvalEvents
        // .filter((a) => a.allowance_relationship == relationshipId)
        .sort((a, b) => Number(b.timestamp) - Number(a.timestamp))[0];
      if (!approval) {
        throw new Error("No approval found");
      }

      const allowance: ApprovalPayload = parse(
        await CipherService.decrypt(
          approval.output_enc_spender,
          spenderAccount.viewer.publicKey,
          spenderAccount.viewer.privateKey
        )
      );
      console.log("allowance", allowance);

      // check if spender has enough allowance
      if (allowance.allowance < props.amount) {
        throw new Error("Insufficient allowance");
      }

      // fetch all notes
      const { notesArray, notesMap, spendingTrackersMap } =
        await notesService.getNotes();

      let spendableNotes = [];

      if (allowance.view.privateKey != 0n) {
        console.log("notesArray", notesArray);
        const res = await Promise.allSettled(
          notesArray.map(async (n) => {
            if (n.spent) {
              return;
            }

            const decrypted: CommitmentPayload = parse(
              await CipherService.decrypt(
                n.encryptedOutput,
                allowance.view.publicKey,
                allowance.view.privateKey
              )
            );

            console.log("decrypted", decrypted, typeof n.commitment, typeof decrypted.bliding);

            const tracker = await DefinitionsService.generateCommitmentTracker(
              n.commitment,
              BigInt("0x" + decrypted.bliding)
            );
            const trackerHash = await BarretenbergService.generateHash(tracker);

            if (spendingTrackersMap.get(formatHex(trackerHash))) {
              throw new Error("Note already spent");
            }

            return {
              commitment: n.commitment,
              encryptedOutput: n.encryptedOutput,
              index: n.index,
              value: BigInt("0x" + decrypted.value),
              bliding: BigInt("0x" + decrypted.bliding),
              trackerHash: trackerHash,
            };
          })
        );
        console.log("res", res);
        spendableNotes = res
          .filter((result) => result.status === "fulfilled")
          .map((result) => (result as PromiseFulfilledResult<any>).value);
      } else {
        spendableNotes = allowance.commitments.filter((c) => {
          const note = notesMap.get(c.commitment);
          return note && !note.spent;
        });
      }

      console.log("spendableNotes", spendableNotes);

      // select note to use for transfer
      const inputNote = spendableNotes
        .sort((a, b) => parseInt((b.value! - a.value!).toString()))
        .find((n) => n.value! > props.amount);
      if (!inputNote) {
        throw new Error("Insufficient funds in notes");
      }

      console.log("inputNote", inputNote)

      const inputCommitmentTracker =
        await DefinitionsService.generateSpendingTracker(
          inputNote.commitment,
          inputNote.bliding!
        );

        console.log("ABC")

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

      console.log("ABC 2")

      // compute input commitment root and path
      const inRoot = tree.getRoot();
      const inputCommitmentProof = tree.getProof(inputNote.commitment);
      if (!inputCommitmentProof) {
        throw new Error("Input commitment doesn't belong to the tree");
      }

      console.log("ABC 2.1.2")

      // generate notes
      const [outOwnerNote, outReceiverNote] = await Promise.all([
        DefinitionsService.generateNote(
          props.from.address,
          props.from.publicKey,
          outOwnerAmount
        ),
        DefinitionsService.generateNote(
          props.to.address,
          props.to.publicKey,
          props.amount
        ),
      ]);

      console.log("ABC 2.1")
      await tree.addCommitment(outOwnerNote.commitment);
      await tree.addCommitment(outReceiverNote.commitment);

      const outRoot = tree.getRoot();
      const outPathProof = tree.getProof(outOwnerNote.commitment);

      const inAllowanceHash = await BarretenbergService.generateHashArray([
        new Fr(props.from.address),
        new Fr(spenderAccount.owner.address),
        new Fr(allowance.allowance),
      ]);

      const outAllowanceHash = await BarretenbergService.generateHashArray([
        new Fr(props.from.address),
        new Fr(spenderAccount.owner.address),
        new Fr(allowance.allowance - props.amount),
      ]);

      console.log("ABC 3")

      const generatedProof = await ProofService.generateTransferFromProof({
        // account details
        owner_account: formatHex(props.from.address),
        receiver_account: formatHex(props.to.address),
        spender_private_key: formatHex(spenderAccount.owner.privateKey),
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

      const { transaction_hash } = await sendAsync([
        contract.populate("transfer_from", [
          generatedProof,
          outOwnerNote.encOutput,
          outReceiverNote.encOutput,
        ]),
      ]);

      return transaction_hash;
    } catch (error) {
      throw error;
    } finally {
      setLoading(false);
    }
  };

  return { sendTransferFrom, loading };
};
