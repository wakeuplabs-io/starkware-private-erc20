import { useState, useEffect } from "react";
import { useNotes } from "./useNotes";
import { NoteExpanded } from "@/interfaces";
import { ProofService } from "@/services/proof.service";
import tokenAbi from "../abi/token.abi";
import {
  useContract,
  useSendTransaction,
} from "@starknet-react/core";
import { encryptNote } from "@/utils/cipher";

export const useTransfer = () => {
  const [recipientAddress, setRecipientAddress] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);
  const [proof, setProof] = useState<Uint16Array | null>(null);
  const [status, setStatus] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const { notes, getProofForCommitment, root, secretKey } = useNotes();

  const PRIVATE_ERC20_CONTRACT_ADDRESS =
    "0x000029f4430cc63c28456d6c5b54029d00338e4c4ec7c873aa1dc1bc3fb38d55";

  // Instancia del contrato
  const { contract } = useContract({
    abi: tokenAbi,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const { send, error: transferError, status: txStatus } = useSendTransaction({
    calls: undefined,
  });

  useEffect(() => {
    console.log({ status });
  }, [status]);

  useEffect(() => {
    console.log({ notes });
  }, [notes]);

  const handleInputChange =
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (setter: React.Dispatch<React.SetStateAction<any>>) =>
      (e: React.ChangeEvent<HTMLInputElement>) => {
        setter(e.target.value);
      };

  async function generateProof({ notesToUse }: { notesToUse: NoteExpanded[] }) {
    setStatus(null);
    setIsLoading(true);
    setProof(null);

    try {
      const proofData = getProofForCommitment(notesToUse[0].commitment);
      if (!proofData) {
        throw new Error("Proof data not found");
      }
      const { path, directionSelector } = proofData;
      const input = {
        amount,
        balance: notesToUse[0].value,
        receiver_address: notesToUse[0].receiver,
        commitment: notesToUse[0].commitment,
        direction_selector: directionSelector,
        nullifier: notesToUse[0].nullifier,
        nullifier_hash: notesToUse[0].nullifierHash,
        path,
        root,
      };

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
    if (!recipientAddress || !recipientPublicKey || amount <= 0 || !secretKey) {
      console.log("Invalid recipient address, public key, or amount");
      return;
    }

    if (!contract) {
      console.log("Contract not initialized");
      return;
    }

    // Ordenar notas de mayor a menor valor
    const noteOrdened = notes.sort((a, b) => b.value - a.value);
    let accumulatedValue = 0;
    const notesToUse = [];

    for (const note of noteOrdened) {
      accumulatedValue += note.value;
      notesToUse.push(note);
      if (accumulatedValue >= amount) break;
    }

    if (accumulatedValue < amount) {
      console.log("Insufficient funds in notes");
      return;
    }

    try {
      const generatedProof = await generateProof({ notesToUse });

      if (!generatedProof) {
        console.log("Proof generation failed");
        return;
      }

      const callData = contract.populate("transfer", [
        root,
        notesToUse[0].nullifierHash,
        notesToUse[0].commitment,
        notesToUse[0].encryptedValue,
        recipientAddress,
        encryptNote({value: amount}, recipientPublicKey, secretKey),
        generatedProof,
      ]);

      console.log("Calling transfer with:", callData);

      await send([callData]);

    } catch (error) {
      console.error("Error sending transfer:", error);
    }
  };

  return {
    recipientAddress,
    setRecipientAddress,
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
