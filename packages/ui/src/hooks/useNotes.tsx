import { useEffect, useState } from "react";
import naclUtil from "tweetnacl-util";
import { useMerkleTree } from "@/hooks/useMerkleTree";
import { useEvents } from "@/hooks/useEvents";
import { NoteExpanded, ReceiverAccount } from "@/interfaces";
import { BarretenbergService } from "@/services/bb.service";
import { CipherService } from "@/services/cipher.service";

export const useNotes = () => {
  const { events, error: eventsError, isLoading: eventsLoading } = useEvents();
  const [notes, setNotes] = useState<NoteExpanded[]>([]);
  const [balance, setBalance] = useState<number>(0);
  const [error, setError] = useState<string | null>(eventsError);
  const [publicKey, setPublicKey] = useState<Uint8Array | null>(null);
  const [secretKey, setSecretKey] = useState<Uint8Array | null>(null);
  const { root, getProofForCommitment, simulateAddCommitments } = useMerkleTree(events);

  useEffect(() => {
    const storedPublicKey = localStorage.getItem("PublicKey");
    const storedSecretKey = localStorage.getItem("SecretKey");

    if (storedPublicKey && storedSecretKey) {
      setPublicKey(naclUtil.decodeBase64(storedPublicKey));
      setSecretKey(naclUtil.decodeBase64(storedSecretKey));
    }
  }, []);

  useEffect(() => {
    if (!events.length || !secretKey || !publicKey) return;

    const fetchNotes = async () => {
      try {
        const storedReceiverAddresses: ReceiverAccount[] = JSON.parse(localStorage.getItem("ReceiverAccounts") || "[]");

        const decryptedNotes = await Promise.all(
          events.map(async (event) => {
            const decrypted = CipherService.decryptNote(event.encryptedValue, secretKey, publicKey);
            const nullifier: string = storedReceiverAddresses.find((receiver) => receiver.address === event.address)?.nullifier || "unknown nullifier";
            const nullifierHash = BarretenbergService.generateHash(nullifier);
            return {
              receiver: event.address,
              value: decrypted.value,
              encryptedValue: event.encryptedValue,
              nullifier,
              nullifierHash,
              commitment: event.commitment,
            };
          })
        );

        const MOCK_NULLIFIER_HASHES = await Promise.all(["0"].map(async (nullifier) =>  BarretenbergService.generateHash(nullifier)));

        const filteredNotes = decryptedNotes.filter(note => !MOCK_NULLIFIER_HASHES.includes(note.nullifierHash));

        setNotes(filteredNotes);
        setBalance(filteredNotes.reduce((acc, note) => acc + note.value, 0));
      } catch (err) {
        console.error("Error decrypting notes:", err);
        setError("Failed to decrypt notes");
      }
    };

    fetchNotes();
  }, [events, secretKey, publicKey]);

  return { notes, balance, error, eventsLoading, secretKey, root, getProofForCommitment, simulateAddCommitments };
};
