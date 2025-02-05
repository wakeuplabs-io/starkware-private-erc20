import { useState } from "react";
import { useNotes } from "./useNotes";
import {
  NoteExpanded,
  SimulateAddCommitmentsResult,
  SimulatedPath,
} from "@/interfaces";
import { ProofService } from "@/services/proof.service";
import { useContract, useSendTransaction } from "@starknet-react/core";
import { BarretenbergService } from "@/services/bb.service";
import { AccountService } from "@/services/account.service";
import { CipherService } from "@/services/cipher.service";
import privateTokenAbi from "@/abi/private-erc20.abi";
import { PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";
import { MerkleTree } from "@/utils/merkle-tree";

export const useTransfer = () => {
  const [publicRecipientAccount, setPublicRecipientAccount] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);
  const [proof, setProof] = useState<Uint16Array | null>(null);
  const [status, setStatus] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
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

  const handleInputChange =
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (setter: React.Dispatch<React.SetStateAction<any>>) =>
      (e: React.ChangeEvent<HTMLInputElement>) => {
        setter(e.target.value);
      };

  async function generateProof({
    notesToUse,
    newRoot,
    receiverData,
    changeData,
  }: {
    notesToUse: NoteExpanded[];
    newRoot: string;
    receiverData: SimulatedPath;
    changeData: SimulatedPath;
  }) {
    setStatus(null);
    setIsLoading(true);
    setProof(null);
    try {
      const proofData = getProofForCommitment(notesToUse[0].commitment);
      if (!proofData) {
        throw new Error("Proof data not found");
      }
      console.log({ commitment: notesToUse[0].commitment });
      const { path, directionSelector } = proofData;
      const input = {
        root,
        path: path,
        direction_selector: directionSelector,
        new_root: newRoot,
        new_path: receiverData.path,
        new_direction_selector: receiverData.directionSelector,
        in_amount: notesToUse[0].value,
        in_commitment_nullifier: notesToUse[0].nullifier,
        in_commitment_nullifier_hash: notesToUse[0].nullifierHash,
        in_commitment_secret: localStorage.getItem("SecretAccount") || "",
        out_amount_sender: notesToUse[0].value - amount,
        out_amount_receiver: amount,
        receiver_account: receiverData.address,
        out_commitments: [receiverData.commitment, changeData.commitment],
      };

      console.log(input);

      const generatedProof = await ProofService.generateProof(input);
      setProof(generatedProof);

      setStatus("Proof generated successfully!");
      return generatedProof;
    } catch (error) {
      setStatus(
        `Error generating proof: ${
          error instanceof Error ? error.message : "Unknown error"
        }`
      );
      throw error;
    } finally {
      setIsLoading(false);
    }
  }

  const sendTransfer = async () => {
    if (!publicRecipientAccount || !recipientPublicKey || amount <= 0) {
      throw new Error("Invalid recipient address, public key, or amount");
    }

    if (!contract) {
      throw new Error("Contract not initialized");
    }

    // order max to min to select the first note with bigger value that can pay the amount
    const inputNote = notes.sort((a, b) => b.value - a.value).find(n => n.value > amount);
    if (!inputNote) {
      throw new Error("Insufficient funds in notes");
    }

    // generate receiver note
    const receiverCommitment = BarretenbergService.generateCommitment(
      publicRecipientAccount,
      amount
    );
    
    // generate change note
    const changeAddress = AccountService.generateReceiverAccount();
    const changeValue = inputNote.value - amount;
    const changeCommitment = BarretenbergService.generateCommitment(
      changeAddress.address,
      changeValue
    );

    // generate tree
    const tree = new MerkleTree()
    
    const orderedNotes = notes.sort((a, b) => a.index - b.index);
    
    const { newRoot, proofs: simulatedPaths }: SimulateAddCommitmentsResult =
      await simulateAddCommitments([receiverCommitment, changeCommitment]);

    const receiverData: SimulatedPath = {
      ...simulatedPaths[0],
      address: publicRecipientAccount,
    };
    const changeData: SimulatedPath = {
      ...simulatedPaths[1],
      address: changeAddress.address,
    };

    try {
      const generatedProof = await generateProof({
        notesToUse,
        newRoot,
        receiverData,
        changeData,
      });
      if (!generatedProof) {
        console.log("Proof generation failed");
        return;
      }

      const callData = contract.populate("transfer", [
        generatedProof,
        notesToUse[0].encryptedValue,
        CipherService.encryptNote(
          { value: amount },
          recipientPublicKey,
          secretKey
        ),
      ]);

      await send([callData]);
    } catch (error) {
      console.error("Error sending transfer:", error);
    }
  };

  return {
    publicRecipientAccount,
    setPublicRecipientAccount,
    recipientPublicKey,
    setRecipientPublicKey,
    amount,
    setAmount,
    proof,
    status,
    isLoading,
    generateProof,
    sendTransfer,
    handleInputChange,
    txStatus,
    transferError,
  };
};
