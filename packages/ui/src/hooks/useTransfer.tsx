import { Fr } from "@aztec/bb.js";
import { useNotes } from "./useNotes";
import { ProofService } from "@/services/proof.service";
import { useContract, useSendTransaction } from "@starknet-react/core";
import { BarretenbergService } from "@/services/bb.service";
import privateTokenAbi from "@/abi/private-erc20.abi";
import { PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";
import { MerkleTree } from "@/utils/merkle-tree";
import { AccountService } from "@/services/account.service";
import { CallData } from "starknet";
import { MERKLE_TREE_DEPTH } from "@/shared/config/constants";

export const useTransfer = () => {
  const { notes } = useNotes();

  const { contract } = useContract({
    abi: privateTokenAbi,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const {
    send,
    error: transferError,
    status: txStatus,
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
    if (!contract) {
      throw new Error("Contract not initialized");
    }

    const spenderAccount = await AccountService.getAccount();

    // order max to min to select the first note with bigger value that can pay the amount
    const senderNotes = notes.filter((n) => !!n.value);
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
      parseInt((b.index! - a.index!).toString())
    );
    for (const note of orderedNotes) {
      tree.addCommitment(note.commitment);
    }
    const inRoot = tree.getRoot();

    const inputCommitmentProof = tree.getProof(inputNote.commitment);
    if (!inputCommitmentProof) {
      throw new Error("Input commitment doesn't belong to the tree");
    }

    await Promise.all([
      tree.addCommitment(outSenderNote.commitment),
      tree.addCommitment(outReceiverNote.commitment)
    ]);

    const outRoot = tree.getRoot();
    const outPathProof = tree.getProof(
      outSenderNote.commitment
    );

    if (!outPathProof) {
      throw new Error("Couldn't generate output path proof");
    }

    try {
      const generatedProof = await ProofService.generateProof({
        in_amount: props.amount.toString(16),
        in_bliding: inputNote.bliding!.toString(16),
        in_commitment_nullifier_hash: BarretenbergService.generateHashArray([
          new Fr(inputNote.nullifier!),
        ]).toString(16),
        in_direction_selector: inputCommitmentProof.directionSelector,
        in_path: inputCommitmentProof.path.map((e) => e.toString(16)),
        in_private_key: spenderAccount.privateKey.toString(16),
        in_root: inRoot.toString(16),
        out_receiver_account: props.to.address.toString(16),
        out_receiver_amount: props.amount.toString(16),
        out_receiver_bliding: outReceiverNote.bliding.toString(16),
        out_receiver_commitment: outReceiverNote.commitment.toString(16),
        out_root: outRoot.toString(16),
        out_sender_amount: outSenderAmount.toString(16),
        out_sender_bliding: outSenderNote.bliding.toString(16),
        out_sender_commitment: outSenderNote.commitment.toString(16),
        out_subtree_root_path: outPathProof.path.slice(0, MERKLE_TREE_DEPTH).map((e) => e.toString(16)),
        out_subtree_root_direction: outPathProof.directionSelector.slice(0, MERKLE_TREE_DEPTH),
      });

      const callData = contract.populate("transfer", [
        generatedProof,
        CallData.compile([outSenderNote.encOutput]),
        CallData.compile([outReceiverNote.encOutput]),
      ]);

      await send([callData]);
    } catch (error) {
      console.error("Error sending transfer:", error);
    }
  };

  return {
    sendTransfer,
    txStatus,
    transferError,
  };
};
