import { Fr } from "@aztec/bb.js";
import { ProofService } from "@/services/proof.service";
import { useContract, useProvider, useSendTransaction } from "@starknet-react/core";
import { BarretenbergService } from "@/services/bb.service";
import { PRIVATE_ERC20_ABI, PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/shared/config/constants";
import { MerkleTree } from "@/lib/merkle-tree";
import { AccountService } from "@/services/account.service";
import { MERKLE_TREE_DEPTH } from "@/shared/config/constants";
import { useMemo, useState } from "react";
import { formatHex } from "@/lib/utils";
import { NotesService } from "@/services/notes.service";
import { Provider } from "starknet";

export const useTransfer = () => {
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

  const sendTransfer = async (props: {
    to: {
      address: bigint;
      publicKey: bigint;
    };
    amount: bigint;
  }) => {
    setLoading(true);

    try {
      if (!contract) {
        throw new Error("Contract not initialized");
      }

      const spenderAccount = await AccountService.getAccount();
      const notes = await notesService.getNotes();

      const senderNotes = notes.filter((n) => n.value !== undefined && n.spent !== true);
      const inputNote = senderNotes
        .sort((a, b) => parseInt((b.value! - a.value!).toString()))
        .find((n) => n.value! > props.amount);
      if (!inputNote) {
        throw new Error("Insufficient funds in notes");
      }

      const outSenderAmount = inputNote.value! - props.amount;

      const [outSenderNote, outReceiverNote] = await Promise.all([
        BarretenbergService.generateNote(
          spenderAccount.address,
          spenderAccount.publicKey,
          outSenderAmount
        ),
        BarretenbergService.generateNote(
          props.to.address,
          props.to.publicKey,
          props.amount
        ),
      ]);

      const tree = new MerkleTree();
      const orderedNotes = notes.sort((a, b) =>
        parseInt((a.index! - b.index!).toString())
      );
      for (const note of orderedNotes) {
        await tree.addCommitment(note.commitment);
      }

      const inRoot = tree.getRoot();
      const inputCommitmentProof = tree.getProof(inputNote.commitment);
      if (!inputCommitmentProof) {
        throw new Error("Input commitment doesn't belong to the tree");
      }

      await tree.addCommitment(outSenderNote.commitment);
      await tree.addCommitment(outReceiverNote.commitment);

      const outRoot = tree.getRoot();
      const outPathProof = tree.getProof(outSenderNote.commitment);

      if (!outPathProof) {
        throw new Error("Couldn't generate output path proof");
      }

      const spendingTracker = await BarretenbergService.generateSpendingTracker(
        inputNote.commitment,
        inputNote.bliding!
      );

      const generatedProof = await ProofService.generateTransferProof({
        owner_private_key: formatHex(spenderAccount.privateKey % Fr.MODULUS),
        receiver_account: formatHex(props.to.address),
        in_commitment_root: formatHex(inRoot),
        in_commitment_path: inputCommitmentProof.path.map((e) => formatHex(e)),
        in_commitment_direction_selector: inputCommitmentProof.directionSelector,
        in_commitment_value: formatHex(inputNote.value!),
        in_commitment_bliding: formatHex(inputNote.bliding!),
        in_commitment_spending_tracker: formatHex(spendingTracker),
        out_receiver_value: formatHex(props.amount),
        out_receiver_bliding: formatHex(outReceiverNote.bliding),
        out_receiver_commitment: formatHex(outReceiverNote.commitment),
        out_sender_value: formatHex(outSenderAmount),
        out_sender_bliding: formatHex(outSenderNote.bliding),
        out_root: formatHex(outRoot),
        out_sender_commitment: formatHex(outSenderNote.commitment),
        // updated root
        out_subtree_root_path: outPathProof.path
          .slice(1, MERKLE_TREE_DEPTH)
          .map((e) => formatHex(e)),
        out_subtree_root_direction:
          outPathProof.directionSelector.slice(1, MERKLE_TREE_DEPTH),
      });

      const callData = contract.populate("transfer", [
        generatedProof,
        outSenderNote.encOutput,
        outReceiverNote.encOutput,
      ]);

      await sendAsync([callData]);
    } catch (error) {
      throw error;
    } finally {
      setLoading(false);
    }
  };

  return {
    sendTransfer,
    loading,
  };
};