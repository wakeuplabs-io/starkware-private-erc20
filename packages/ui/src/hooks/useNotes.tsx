import { useEffect, useState } from "react";
import naclUtil from "tweetnacl-util";
import { useMerkleTree } from "@/hooks/useMerkleTree";
import { useEvents } from "@/hooks/useEvents";
import { NoteExpanded, ReceiverAccount } from "@/interfaces";
import { BarretenbergService } from "@/services/bb.service";
import { CipherService } from "@/services/cipher.service";

export const useNotes = () => {
  const { commitments, nullifierHashes, error: eventsError, isLoading: eventsLoading } = useEvents();
  const [notes, setNotes] = useState<NoteExpanded[]>([]);
  const [balance, setBalance] = useState<number>(0);
  const [error, setError] = useState<string | null>(eventsError);
  const [publicKey, setPublicKey] = useState<Uint8Array | null>(null);
  const [secretKey, setSecretKey] = useState<Uint8Array | null>(null);
  const { root, getProofForCommitment, simulateAddCommitments } = useMerkleTree(commitments);

  useEffect(() => {
    const storedPublicKey = localStorage.getItem("PublicKey");
    const storedSecretKey = localStorage.getItem("SecretKey");

    if (storedPublicKey && storedSecretKey) {
      setPublicKey(naclUtil.decodeBase64(storedPublicKey));
      setSecretKey(naclUtil.decodeBase64(storedSecretKey));
    }
  }, []);

  useEffect(() => {
    if (!commitments.length || !secretKey || !publicKey) return;

    const fetchNotes = async () => {
      try {
        const storedReceiverAddresses: ReceiverAccount[] = JSON.parse(localStorage.getItem("ReceiverAccounts") || "[]");

        const decryptedNotes = await Promise.all(
          commitments.map(async (commitments) => {
            const decrypted = CipherService.decryptNote(commitments.encryptedValue, secretKey, publicKey);
            const nullifier: string = storedReceiverAddresses.find((receiver) => receiver.address === commitments.address)?.nullifier || "unknown nullifier";
            const nullifierHash = BarretenbergService.generateHash(nullifier);
            return {
              receiver: commitments.address,
              value: decrypted.value,
              encryptedValue: commitments.encryptedValue,
              nullifier,
              nullifierHash,
              commitment: commitments.commitment,
            };
          })
        );

        const filteredNotes = decryptedNotes.filter(note => !nullifierHashes.includes(note.nullifierHash));

        setNotes(filteredNotes);
        setBalance(filteredNotes.reduce((acc, note) => acc + note.value, 0));
      } catch (err) {
        console.error("Error decrypting notes:", err);
        setError("Failed to decrypt notes");
      }
    };

    fetchNotes();
  }, [commitments, nullifierHashes, secretKey, publicKey]);

  return { notes, balance, error, eventsLoading, secretKey, root, getProofForCommitment, simulateAddCommitments };
};
