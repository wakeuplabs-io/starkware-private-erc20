import { ProofService } from "@/services/proof.service";
import {
  useContract,
  useSendTransaction,
} from "@starknet-react/core";
import { BarretenbergService } from "@/services/bb.service";
import {
  PRIVATE_ERC20_ABI,
  PRIVATE_ERC20_CONTRACT_ADDRESS,
} from "@/shared/config/constants";
import { MerkleTree } from "@/lib/merkle-tree";
import { AccountService } from "@/services/account.service";
import { MERKLE_TREE_DEPTH } from "@/shared/config/constants";
import { useState } from "react";
import { formatHex } from "@/lib/utils";
import { notesService } from "@/services/notes.service";

export const useDeposit = () => {
  const [loading, setLoading] = useState(false);

  const { contract } = useContract({
    abi: PRIVATE_ERC20_ABI,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const { sendAsync } = useSendTransaction({
    calls: undefined,
  });

  const sendDeposit = async (props: {
    amount: bigint;
  }): Promise<string> => {
    setLoading(true);

    try {
      if (!contract) {
        throw new Error("Contract not initialized");
      }

      const callerAccount = await AccountService.getAccount();
      const { notesArray: notes } = await notesService.getNotes();

      const outReceiverNote = await BarretenbergService.generateNote(
        callerAccount.address,
        callerAccount.publicKey,
        props.amount
      );

      const tree = new MerkleTree();
      const orderedNotes = notes.sort((a, b) =>
        parseInt((a.index! - b.index!).toString())
      );
      console.log({orderedNotes});
      for (const note of orderedNotes) {
        await tree.addCommitment(note.commitment);
      }

      const inRoot = tree.getRoot();

      await tree.addCommitment(outReceiverNote.commitment);
      await tree.addCommitment(0n);
      const outRoot = tree.getRoot();
      const outPathProof = tree.getProof(outReceiverNote.commitment);
      console.log(formatHex(inRoot));
      console.log({
        // accounts details
        receiver_account: formatHex(callerAccount.address),
        // utxo inputs
        in_commitment_root: formatHex(inRoot),
        // utxo outputs
        out_receiver_commitment_value: formatHex(props.amount),
        out_receiver_commitment_bliding: formatHex(outReceiverNote.bliding),
        out_receiver_commitment: formatHex(outReceiverNote.commitment),
        // updated root
        out_root: formatHex(outRoot),
        out_subtree_root_path: outPathProof.path
          .slice(1, MERKLE_TREE_DEPTH)
          .map((e) => formatHex(e)),
        out_subtree_root_direction_selector:
          outPathProof.directionSelector.slice(1, MERKLE_TREE_DEPTH),
      });

      const generatedProof = await ProofService.generateDepositProof({
        // accounts details
        receiver_account: formatHex(callerAccount.address),
        // utxo inputs
        in_commitment_root: formatHex(inRoot),
        // utxo outputs
        out_receiver_commitment_value: formatHex(props.amount),
        out_receiver_commitment_bliding: formatHex(outReceiverNote.bliding),
        out_receiver_commitment: formatHex(outReceiverNote.commitment),
        // updated root
        out_root: formatHex(outRoot),
        out_subtree_root_path: outPathProof.path
          .slice(1, MERKLE_TREE_DEPTH)
          .map((e) => formatHex(e)),
        out_subtree_root_direction_selector:
          outPathProof.directionSelector.slice(1, MERKLE_TREE_DEPTH),
      });

      const { transaction_hash } = await sendAsync([
        contract.populate("deposit", [
          generatedProof,
        ]),
      ]);

      return transaction_hash;
    } finally {
      setLoading(false);
    }
  };

  return {
    sendDeposit,
    loading,
  };
};
