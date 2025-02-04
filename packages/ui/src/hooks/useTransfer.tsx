import { useState, useEffect } from "react";
import { useNotes } from "./useNotes";
import { NoteExpanded, SimulateAddCommitmentsResult, SimulatedPath } from "@/interfaces";
import { ProofService } from "@/services/proof.service";
import {
  useContract,
  useSendTransaction,
} from "@starknet-react/core";
import { BarretenbergService } from "@/services/bb.service";
import { AccountService } from "@/services/account.service";
import { CipherService } from "@/services/cipher.service";
import privateTokenAbi from "@/abi/private-erc20.abi";

export const useTransfer = () => {
  const [publicRecipientAccount, setPublicRecipientAccount] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);
  const [proof, setProof] = useState<Uint16Array | null>(null);
  const [status, setStatus] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const { notes, getProofForCommitment, root, secretKey, simulateAddCommitments } = useNotes();
  const PRIVATE_ERC20_CONTRACT_ADDRESS =
    "0x000029f4430cc63c28456d6c5b54029d00338e4c4ec7c873aa1dc1bc3fb38d55";

  const { contract } = useContract({
    abi: privateTokenAbi,
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

  async function generateProof({ notesToUse, newRoot, receiverData, changeData }: { notesToUse: NoteExpanded[], newRoot: string, receiverData: SimulatedPath, changeData:SimulatedPath }) {
    setStatus(null);
    setIsLoading(true);
    setProof(null);
    try {
      const proofData = getProofForCommitment(notesToUse[0].commitment);
      if (!proofData) {
        throw new Error("Proof data not found");
      }
      console.log({commitment: notesToUse[0].commitment});
      const { path, directionSelector } = proofData;
      const input = {
        balance: notesToUse[0].value,
        amount,
        receiver_account: receiverData.address ,
        change_account: changeData.address,
        secret_sender_account: localStorage.getItem("SecretAccount") || "",
        nullifier: notesToUse[0].nullifier,
        nullifier_hash: notesToUse[0].nullifierHash,
        root,
        path: path,
        direction_selector: directionSelector,
        out_commitment: [receiverData.commitment, changeData.commitment],
        new_root: newRoot,
        new_path: receiverData.path,
        new_direction_selector: receiverData.directionSelector,
        new_path_change: changeData.path,
        new_direction_selector_change: changeData.directionSelector
      };

      console.log(input);

      const generatedProof = await ProofService.generateProof(input);
      setProof(generatedProof);
      setStatus("Proof generated successfully!");
      return "generatedProof";
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
    console.log({
      publicRecipientAccount,
      recipientPublicKey,
      amount,
      secretKey
    });
    if (!publicRecipientAccount || !recipientPublicKey || amount <= 0 || !secretKey) {
      console.log("Invalid recipient address, public key, or amount");
      return;
    }

    if (!contract) {
      console.log("Contract not initialized");
      return;
    }

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
    const receiverCommitment = BarretenbergService.generateCommitment(publicRecipientAccount, amount );
    const changeAddress = AccountService.generateReceiverAccount();
    const changeValue = accumulatedValue - amount;
    const changeCommitment = BarretenbergService.generateCommitment(changeAddress.address, changeValue );
    const { newRoot, proofs: simulatedPaths} : SimulateAddCommitmentsResult = await simulateAddCommitments([receiverCommitment, changeCommitment]);


    const receiverData: SimulatedPath = {
      ...simulatedPaths[0],
      address: publicRecipientAccount
    };
    const changeData: SimulatedPath = {
      ...simulatedPaths[1],
      address: changeAddress.address
    };
    try {
      const generatedProof = await generateProof({ notesToUse, newRoot, receiverData, changeData });

      if (!generatedProof) {
        console.log("Proof generation failed");
        return;
      }

      const callData = contract.populate("transfer", [

        notesToUse[0].encryptedValue,
        publicRecipientAccount,
        CipherService.encryptNote({value: amount}, recipientPublicKey, secretKey),
        generatedProof,
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
