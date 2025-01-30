import { useEffect, useState } from "react";
import { useNetwork } from "@starknet-react/core";
import naclUtil from "tweetnacl-util";
import { decryptNote, encryptNote, generateCommitment, generateHash } from "@/utils/cipher";
import { CommitmentEvent, NoteExpanded, ReceiverAccount } from "@/interfaces";
import { SHA256 } from "crypto-js";
import { useMerkleTree } from "@/hooks/useMerkleTree";

const MOCK_NOTES = [
  { receiver: "a1a03444c5e440f16936d2baa0b7e67e75b55a2fd6a8d59650fcfd03dd833aaf", value: 100, nullifier: "0" },
  { receiver: "ad93260fc550f682c2d9fa376c6094bb9a9f07ad6d52308f7bef2b7e564f989c", value: 200, nullifier: "1" },
  { receiver: "92125e0b6fd962e370e09dde9fd9dea852d87912d131472ec9cc67a08359ea8a", value: 300, nullifier: "2" },
];

const MOCK_NULLIFIER_HASHES = [ SHA256("1").toString() ];

export const useNotes = () => {
  const { chain } = useNetwork();
  const [events, setEvents] = useState<CommitmentEvent[]>([]);
  const [notes, setNotes] = useState<NoteExpanded[]>([]);
  const [balance, setBalance] = useState<number>(0);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [publicKey, setPublicKey] = useState<Uint8Array | null>(null);
  const [secretKey, setSecretKey] = useState<Uint8Array | null>(null);
  const { merkleTree, root } = useMerkleTree(events);

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
          MOCK_NOTES.map(async (note, index) => {
            const encryptedValue = encryptNote({ value: note.value }, publicKey, secretKey);
            const commitment = await generateCommitment(note.value, note.receiver, index);
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
              nullifier, 
              nullifierHash, 
              commitment: event.commitment 
            };
          })
        );
  
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

  return { notes, balance, error, isLoading, secretKey, merkleTree, root };
};

