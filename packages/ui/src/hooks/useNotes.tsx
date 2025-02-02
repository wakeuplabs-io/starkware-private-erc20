import { useEffect, useState } from "react";
import { useNetwork } from "@starknet-react/core";
import naclUtil from "tweetnacl-util";
import { decryptNote, encryptNote, generateCommitment, generateHash } from "@/utils/cipher";
import { CommitmentEvent, NoteExpanded, ReceiverAccount } from "@/interfaces";
import { useMerkleTree } from "@/hooks/useMerkleTree";

const MOCK_NOTES = [
  { receiver: "0xe468ab33ddc47f5235a00c38ff657eac818586e2", value: 100, nullifier: "0" },
  { receiver: "0x9bc903a0dd19b724c87eaaa3a6b9de1b7e043a3b", value: 200, nullifier: "1" },
  { receiver: "0x1cac4b5a6f3c8391aae7981b4a2e60a60be57c7c", value: 300, nullifier: "2" },
];



export const useNotes = () => {
  const { chain } = useNetwork();
  const [events, setEvents] = useState<CommitmentEvent[]>([]);
  const [notes, setNotes] = useState<NoteExpanded[]>([]);
  const [balance, setBalance] = useState<number>(0);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [publicKey, setPublicKey] = useState<Uint8Array | null>(null);
  const [secretKey, setSecretKey] = useState<Uint8Array | null>(null);
  const { merkleTree, root, getProofForCommitment } = useMerkleTree(events);

  useEffect(() => {
    const storedPublicKey = localStorage.getItem("PublicKey");
    const storedSecretKey = localStorage.getItem("SecretKey");

    if (storedPublicKey && storedSecretKey) {
      setPublicKey(naclUtil.decodeBase64(storedPublicKey));
      setSecretKey(naclUtil.decodeBase64(storedSecretKey));
    }
  }, []);

  useEffect(() => {
    if (!chain || !publicKey || !secretKey) return;
    setIsLoading(true);
  
    const fetchEvents = async () => {
      try {
        const encryptedNotes = await Promise.all(
          MOCK_NOTES.map(async (note) => {
            const encryptedValue = encryptNote({ value: note.value }, publicKey, secretKey);
            const commitment = await generateCommitment(note.value, note.receiver);
            return { commitment, encryptedValue, address: note.receiver };
          })
        );
  
        setEvents(encryptedNotes);
      } catch (err) {
        console.error("Error fetching notes:", err);
        setError("Failed to fetch notes");
      } finally {
        setIsLoading(false);
      }
    };
  
    fetchEvents();
  }, [chain, publicKey, secretKey]);
  

  useEffect(() => {
    const fetchNotes = async () => {

      if (!events.length || !secretKey || !publicKey) return;
  
      try {
        const storedReceiverAddresses: ReceiverAccount[] = JSON.parse(localStorage.getItem("ReceiverAccounts") || "[]");
  
        const decryptedNotes = await Promise.all(
          events.map(async (event) => {
            const decrypted = decryptNote(event.encryptedValue, secretKey, publicKey);
            const nullifier: string = storedReceiverAddresses.find((receiver) => receiver.address === event.address)?.nullifier || "unknown nullifier";
            const nullifierHash = await generateHash(nullifier);
            return { 
              receiver: event.address, 
              value: decrypted.value, 
              encryptedValue: event.encryptedValue,
              nullifier, 
              nullifierHash, 
              commitment: event.commitment 
            };
          })
        );
        const MOCK_NULLIFIER_HASHES = await Promise.all(["0"].map(async (nullifier) => {
          return await generateHash(nullifier);
        }));
        const filteredNotes = decryptedNotes.filter(note => {
          return !MOCK_NULLIFIER_HASHES.includes(note.nullifierHash);
        });
  
        setNotes(filteredNotes);
        setBalance(filteredNotes.reduce((acc, note) => acc + note.value, 0));
      } catch (err) {
        console.error("Error decrypting notes:", err);
        setError("Failed to decrypt notes");
      }
    };
    fetchNotes();
  }, [events, secretKey, publicKey]);

  return { notes, balance, error, isLoading, secretKey, merkleTree, root, getProofForCommitment };
};

