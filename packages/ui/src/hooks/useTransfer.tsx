import { Fr } from "@aztec/bb.js";
import { useNotes } from "./useNotes";
import { ProofService } from "@/services/proof.service";
import {
  useAccount,
  useContract,
  useSendTransaction,
} from "@starknet-react/core";
import { BarretenbergService } from "@/services/bb.service";
import privateTokenAbi from "@/abi/private-erc20.abi";
import { PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";
import { MerkleTree } from "@/utils/merkle-tree";
import { AccountService } from "@/services/account.service";
import { byteArray, CallData } from "starknet";
import { MERKLE_TREE_DEPTH } from "@/constants";
import { useState } from "react";
import { formatHex } from "@/utils/hex";

export const useTransfer = () => {
  const { notes } = useNotes();
  const [loading, setLoading] = useState(false);
  const { account } = useAccount();

  const { contract } = useContract({
    abi: privateTokenAbi,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const {
    sendAsync
  } = useSendTransaction({
    calls: undefined,
  });

  const sendTransfer = async (props: {
    to: {
      address: bigint;
      publicKey: bigint;
    };
    amount: bigint;
  }) => {
    try {
      if (!contract) {
        throw new Error("Contract not initialized");
      }

      const spenderAccount = await AccountService.getAccount();

      // order max to min to select the first note with bigger value that can pay the amount
      const senderNotes = notes.filter((n) => n.value !== undefined);
      const inputNote = senderNotes
        .sort((a, b) => parseInt((b.value! - a.value!).toString()))
        .find((n) => n.value! > props.amount);
      if (!inputNote) {
        throw new Error("Insufficient funds in notes");
      }

      // generate output notes

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

      // generate tree and merkle proofs for input and output

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

      const nullifier = await BarretenbergService.generateHashArray([
        new Fr(inputNote.commitment),
        new Fr(spenderAccount.privateKey % Fr.MODULUS),
        ...inputCommitmentProof.path.map((e) => new Fr(e)),
      ]);
      const nullifierHash = await BarretenbergService.generateHashArray([
        new Fr(nullifier),
      ]);

      const generatedProof = await ProofService.generateProof({
        in_amount: formatHex(inputNote.value!),
        in_bliding: formatHex(inputNote.bliding!),
        in_commitment_nullifier_hash: formatHex(nullifierHash),
        in_direction_selector: inputCommitmentProof.directionSelector,
        in_path: inputCommitmentProof.path.map((e) => formatHex(e)),
        in_private_key: formatHex(spenderAccount.privateKey % Fr.MODULUS),
        in_root: formatHex(inRoot),
        out_receiver_account: formatHex(props.to.address),
        out_receiver_amount: formatHex(props.amount),
        out_receiver_bliding: formatHex(outReceiverNote.bliding),
        out_receiver_commitment: formatHex(outReceiverNote.commitment),
        out_root: formatHex(outRoot),
        out_sender_amount: formatHex(outSenderAmount),
        out_sender_bliding: formatHex(outSenderNote.bliding),
        out_sender_commitment: formatHex(outSenderNote.commitment),
        out_subtree_root_path: outPathProof.path
          .slice(1, MERKLE_TREE_DEPTH)
          .map((e) => formatHex(e)),
        out_subtree_root_direction: outPathProof.directionSelector.slice(
          1,
          MERKLE_TREE_DEPTH
        ),
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
