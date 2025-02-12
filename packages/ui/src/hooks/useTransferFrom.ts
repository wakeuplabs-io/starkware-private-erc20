import { useState } from "react";
import { useContract, useSendTransaction } from "@starknet-react/core";
import privateTokenAbi from "@/abi/private-erc20.abi";
import { MERKLE_TREE_DEPTH, PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";
import { Note } from "@/interfaces";
import { ProofService } from "@/services/proof.service";
import { Fr } from "@aztec/bb.js";
import { AccountService } from "@/services/account.service";
import { BarretenbergService } from "@/services/bb.service";
import { formatHex } from "@/lib/utils";
import { MerkleTree } from "@/lib/merkle-tree";

export const useTransferFrom = () => {
  // const { notes } = useNotes();
  const notes = [] as Note[];
  const [loading, setLoading] = useState(false);

  const { contract } = useContract({
    abi: privateTokenAbi,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const { sendAsync } = useSendTransaction({
    calls: undefined,
  });

  const sendTransferFrom = async (props: {
    from: { address: bigint; publicKey: bigint };
    to: { address: bigint; publicKey: bigint };
    amount: bigint;
  }) => {
    setLoading(true);

    console.log(props.from);
    try {
      if (!contract) {
        throw new Error("Contract not initialized");
      }
      setLoading(true);

      const senderNotes = notes.filter((n) => n.value !== undefined);
      const inputNote = senderNotes
        .sort((a, b) => parseInt((b.value! - a.value!).toString()))
        .find((n) => n.value! > props.amount);
        
      if (!inputNote) {
        throw new Error("Insufficient funds in notes");
      }

      const outSenderAmount = inputNote.value! - props.amount;
      const callerAccount = await AccountService.getAccount();

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

      const [outSenderNote, outReceiverNote] = await Promise.all([
        BarretenbergService.generateNote(
          callerAccount.address,
          callerAccount.publicKey,
          outSenderAmount
        ),
        BarretenbergService.generateNote(
          props.to.address,
          props.to.publicKey,
          props.amount
        ),
      ]);
      await tree.addCommitment(outSenderNote.commitment);
      await tree.addCommitment(outReceiverNote.commitment);

      const outRoot = tree.getRoot();
      const outPathProof = tree.getProof(outSenderNote.commitment);

      const generatedProof = await ProofService.generateTransferFromProof({
        // account details
        owner_account: formatHex(props.from.address),
        receiver_account: formatHex(props.to.address),
        spender_private_key: formatHex(callerAccount.privateKey % Fr.MODULUS),
        // input commitment details
        in_commitment_root: formatHex(inRoot),
        in_commitment_path: inputCommitmentProof.path.map((e) => formatHex(e)),
        in_commitment_direction_selector: inputCommitmentProof.directionSelector,
        in_commitment_bliding: formatHex(inputNote.bliding!),
        in_commitment_value: formatHex(inputNote.value!),
        in_commitment_spending_tracker: formatHex(inputNote.value!),
        in_allowance_value: formatHex(inputNote.value!),
        in_allowance_hash: formatHex(inputNote.value!),
        in_allowance_relationship: formatHex(inputNote.value!),

        out_allowance_hash: formatHex(outReceiverNote.bliding),
        out_receiver_value: formatHex(outSenderAmount),
        out_receiver_bliding: formatHex(outReceiverNote.bliding),
        out_receiver_commitment: formatHex(outReceiverNote.commitment),
        out_owner_value: formatHex(outRoot),
        out_owner_bliding: formatHex(outRoot),
        out_owner_commitment: formatHex(outRoot),
        out_root: formatHex(outRoot),
        out_subtree_root_path: outPathProof.path
          .slice(1, MERKLE_TREE_DEPTH)
          .map((e) => formatHex(e)),
        out_subtree_direction_selector: outPathProof.directionSelector.slice(
          1,
          MERKLE_TREE_DEPTH
        ),
      });

      const callData = contract.populate("transferFrom", [
        generatedProof,
        outSenderNote.encOutput,
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
