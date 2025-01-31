import { useState, useEffect } from "react";

import { ProofData, UltraHonkBackend } from "@aztec/bb.js";
import { useNotes } from "./useNotes";
import { NoteExpanded } from "@/interfaces";

import initNoirC from "@noir-lang/noirc_abi";
import initACVM from "@noir-lang/acvm_js";
import acvm from "@noir-lang/acvm_js/web/acvm_js_bg.wasm?url";
import noirc from "@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm?url";
import { CompiledCircuit, Noir } from "@noir-lang/noir_js";


await Promise.all([initACVM(fetch(acvm)), initNoirC(fetch(noirc))]);

export const useTransfer = ({ acir }: { acir: CompiledCircuit }) => {
  const [recipientAddress, setRecipientAddress] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);
  const [proof, setProof] = useState<ProofData | null>(null);
  const [status, setStatus] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const { notes, getProofForCommitment, root } = useNotes();


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

  async function generateProof({
    notesToUse,
  }: {
    notesToUse: NoteExpanded[];
  }): Promise<void> {
    setStatus(null);
    setIsLoading(true);
    setProof(null);
    try {
      if (acir) {
        const acirCircuit: CompiledCircuit = acir;
        const noir = new Noir(acirCircuit);
        const backend = new UltraHonkBackend(acirCircuit.bytecode);
        const proofData = getProofForCommitment(notesToUse[0].commitment);
        if (!proofData) {
          throw new Error("Proof data not found");
        }
        const { path, directionSelector } = proofData;
        const input = {
          amount: 100,
          balance: notesToUse[0].value,
          receiver_address: notesToUse[0].receiver,
          commitment: notesToUse[0].commitment,
          direction_selector: directionSelector,
          nullifier: notesToUse[0].nullifier,
          nullifier_hash: notesToUse[0].nullifierHash,
          path: path,
          root: root,
        };


        const { witness } = await noir.execute(input);
        const generatedProof = await backend.generateProof(witness);
        setProof(generatedProof);
        setStatus("Proof generated successfully!");
      }
    } catch (error) {
      setStatus(
        `Error generating proof: ${
          error instanceof Error ? error.message : "Unknown error"
        }`
      );
    } finally {
      setIsLoading(false);
    }
  }

  const sendTransfer = async () => {
    if (!recipientAddress || !recipientPublicKey || amount <= 0) {
      console.log("Invalid recipient address, public key, or amount");
      return;
    }

    console.log("Transfer Data:", {
      recipientAddress,
      recipientPublicKey,
      amount,
      proof,
    });

    const noteOrdened = notes.sort((a, b) => b.value - a.value);
    console.log("Note Ordened:", noteOrdened);

    let accumulatedValue = 0;
    const notesToUse = [];

    for (const note of noteOrdened) {
      accumulatedValue += note.value;
      notesToUse.push(note);
      if (accumulatedValue >= amount) {
        break;
      }
    }

    if (accumulatedValue < amount) {
      console.log("Insufficient funds in notes");
      return;
    }
    generateProof({ notesToUse });
    console.log("Notes to use:", notesToUse);
    console.log("Transfer simulated successfully!");
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
  };
};
