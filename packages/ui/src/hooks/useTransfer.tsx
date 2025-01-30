import { useState, useEffect } from "react";
import { CompiledCircuit, Noir } from "@noir-lang/noir_js";
import { ProofData } from "@aztec/bb.js";
// import { ProofData, UltraHonkBackend } from "@aztec/bb.js";
import { useNotes } from "./useNotes";
import { NoteExpanded } from "@/interfaces";


export const useTransfer = ({ acir }: { acir: CompiledCircuit}) => {
  const [recipientAddress, setRecipientAddress] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);
  const [proof, setProof] = useState<ProofData | null>(null);
  const [status, setStatus] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const { notes } = useNotes();

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

  async function generateProof({ notesToUse }: { notesToUse : NoteExpanded[]}): Promise<void> {
    setStatus(null);
    setIsLoading(true);
    setProof(null);
    try {
      if (acir) {
        const acirCircuit : CompiledCircuit = acir;
        const noir = new Noir(acirCircuit);
        // const backend = new UltraHonkBackend(acirCircuit.bytecode);

        const input = {
          amount: amount,
          balance: notesToUse[0].value,
          commitment: notesToUse[0].commitment,
          root: "0x...",
          path: ["0x...", "0x..."],
          direction_selector: [false, false],
          nullifier: notesToUse[0].nullifier,
          nullifier_hash: notesToUse[0].nullifierHash,
        };

        const { witness } = await noir.execute(input);
        console.log("Witness:", witness);
        // const generatedProof = await backend.generateProof(witness);
        // setProof(generatedProof);
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
