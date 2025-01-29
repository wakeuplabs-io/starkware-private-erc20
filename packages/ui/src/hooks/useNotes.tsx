import { useEffect, useState } from "react";
import { useNetwork } from "@starknet-react/core";
import naclUtil from "tweetnacl-util";
import { decryptNote, encryptNote, generateCommitment } from "@/utils/cipher";
import { CommitmentEvent, Note, ReceiverAccount } from "@/interfaces";
import { SHA256 } from "crypto-js";

const MOCK_NOTES = [
  { receiver: "201075e34891632358902c3e590c4ba2b2989622b6142c06de8a28826d2f8b85", value: 100, nullifier: "0" },
  { receiver: "66b78d2e6cfdc1b9394c0dfec78c03cf357a241e174cd4117a09fe697660a9f7", value: 200, nullifier: "1" },
  { receiver: "ede92857e44ca5e90d9f97c20cd085a47b38bed835a4b68ec6ea1083472e6a1c", value: 300, nullifier: "2" },
];

const MOCK_NULLIFIER_HASHES = [ SHA256("0").toString() ];

export const useNotes = () => {
  const { chain } = useNetwork();
  const [events, setEvents] = useState<CommitmentEvent[]>([]);
  const [notes, setNotes] = useState<Note[]>([]);
  const [balance, setBalance] = useState<number>(0);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [publicKey, setPublicKey] = useState<Uint8Array | null>(null);
  const [secretKey, setSecretKey] = useState<Uint8Array | null>(null);

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
    try {
      const encryptedNotes = MOCK_NOTES.map((note, index) => {
        const encryptedValue = encryptNote({ value: note.value }, publicKey, secretKey);
        const commitment = generateCommitment(note.value, note.receiver, index);
        return { commitment, encryptedValue, address: note.receiver };
      });
      console.log("encryptedNotes", encryptedNotes);
      setEvents(encryptedNotes);
    } catch (err) {
      console.error("Error fetching notes:", err);
      setError("Failed to fetch notes");
    } finally {
      setIsLoading(false);
    }

  }, [chain, publicKey, secretKey]);

  useEffect(() => {
    if (!events.length || !secretKey || !publicKey) return;

    try {
      const storedReceiverAddresses: ReceiverAccount[] = JSON.parse(localStorage.getItem("ReceiverAccounts") || "[]");

      const decryptedNotes = events.map((event) => {
        const decrypted = decryptNote(event.encryptedValue, secretKey, publicKey);
        console.log(storedReceiverAddresses);
        console.log(events);
        const nullifier = storedReceiverAddresses.find((receiver) => receiver.address === event.address)?.nullifier;
        return { receiver: event.address, value: decrypted.value, nullifier };
      });
      const filteredNotes = decryptedNotes.filter(note => {
        if (!note.nullifier) return true;
        const hashedNullifier = SHA256(note.nullifier).toString();
        return !MOCK_NULLIFIER_HASHES.includes(hashedNullifier);
      });

      setNotes(filteredNotes);
      setBalance(filteredNotes.reduce((acc, note) => acc + note.value, 0));
    } catch (err) {
      console.error("Error decrypting notes:", err);
      setError("Failed to decrypt notes");
    }
  }, [events, secretKey, publicKey]);


  console.log("notes", balance);
  return { notes, balance, error, isLoading };
};

