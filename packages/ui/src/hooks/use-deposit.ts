import { ProofService } from "@/services/proof.service";
import {
  useAccount,
  useContract,
  useSendTransaction,
} from "@starknet-react/core";
import {
  ENIGMA_ABI,
  ENIGMA_CONTRACT_ADDRESS,
  ENG_TO_ETH_RATIO,
  ETH_ABI,
  ETH_CONTRACT_ADDRESS,
} from "@/shared/config/constants";
import { MerkleTree } from "@/lib/merkle-tree";
import { AccountService } from "@/services/account.service";
import { MERKLE_TREE_DEPTH } from "@/shared/config/constants";
import { useState } from "react";
import { formatHex } from "@/lib/utils";
import { notesService } from "@/services/notes.service";
import { DefinitionsService } from "@/services/definitions.service";

export const useDeposit = () => {
  const [loading, setLoading] = useState(false);

  const { address } = useAccount();

  const { contract: enigmaContract } = useContract({
    abi: ENIGMA_ABI,
    address: ENIGMA_CONTRACT_ADDRESS,
  });

  const { contract: ethContract } = useContract({
    abi: ETH_ABI,
    address: ETH_CONTRACT_ADDRESS,
  });

  const { sendAsync } = useSendTransaction({
    calls: undefined,
  });

  const sendDeposit = async (props: { amount: bigint }): Promise<string> => {
    setLoading(true);
    try {
      if (!enigmaContract || !ethContract) {
        throw new Error("Contract not initialized");
      }

      const ethAmount = props.amount * ENG_TO_ETH_RATIO;

      // approve ETH
      const allowance = await ethContract.call("allowance", [
        address,
        ENIGMA_CONTRACT_ADDRESS,
      ]);
      if (allowance < ethAmount) {
        await sendAsync([
          ethContract.populate("approve", [ENIGMA_CONTRACT_ADDRESS, ethAmount]),
        ]);
      }

      // build deposit note
      const callerAccount = await AccountService.getAccount();
      const outReceiverNote = await DefinitionsService.note(
        callerAccount.owner.address,
        callerAccount.viewer.publicKey,
        ethAmount
      );

      // generate deposit proof
      const { notesArray: notes } = await notesService.getNotes();

      const tree = new MerkleTree();

      const orderedNotes = notes.sort((a, b) =>
        parseInt((a.index! - b.index!).toString())
      );
      for (const note of orderedNotes) {
        await tree.addCommitment(note.commitment);
      }

      const inRoot = tree.getRoot();

      await tree.addCommitment(outReceiverNote.commitment);
      await tree.addCommitment(0n);
      const outRoot = tree.getRoot();
      const outPathProof = tree.getProof(outReceiverNote.commitment);

      const depositProof = await ProofService.generateDepositProof({
        // accounts details
        receiver_account: formatHex(callerAccount.owner.address),
        // utxo inputs
        in_commitment_root: formatHex(inRoot),
        in_public_amount: formatHex(props.amount),
        // utxo outputs
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
        enigmaContract.populate("deposit", [
          depositProof,
          outReceiverNote.encOutput,
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
