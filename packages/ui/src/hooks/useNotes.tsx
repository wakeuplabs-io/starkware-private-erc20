import { useMemo } from "react";
import { useEvents } from "@/hooks/useEvents";
import { Note, ReceiverAccount } from "@/interfaces";
import { BarretenbergService } from "@/services/bb.service";
import { CipherService } from "@/services/cipher.service";
import { AccountService } from "@/services/account.service";

export const useNotes: () => {
  notes: Note[],
  balance: bigint,
  loading: boolean
} = () => {
  const {
    commitments,
    nullifierHashes,
    isLoading: eventsLoading,
  } = useEvents();

  const { notes, balance } = useMemo(async () => {
    try {
      if (!commitments.length) {
        throw new Error("No commitments");
      }

      const { publicKey, privateKey } = await AccountService.getAccount();
      const storedReceiverAddresses: ReceiverAccount[] = JSON.parse(
        localStorage.getItem("ReceiverAccounts") || "[]"
      );

      const notes = commitments
        .map((commitment) => {
          const decrypted = CipherService.decrypt(
            commitment.encryptedValue,
            publicKey,
            privateKey,
          );

          const nullifier: string =
            storedReceiverAddresses.find(
              (receiver) => receiver.address === commitment.address
            )?.nullifier || "unknown nullifier";

          const nullifierHash = BarretenbergService.generateHash(nullifier);
          const note: Note = {
            index: commitment.index
            receiver: commitments.address,
            value: decrypted.value,
            encryptedValue: commitments.encryptedValue,
            nullifier,
            nullifierHash,
            commitment: commitments.commitment,
          };

          return note;
        })
        .filter((note) => !nullifierHashes.includes(note.nullifierHash)); // TODO: should return all notes, and then we filter in transfer

      return {
        notes,
        balance: notes.reduce((acc, note) => acc + note.value, 0),
      };
    } catch (e) {
      return { notes: [], balance: 0 };
    }
  }, [commitments, nullifierHashes]);

  return { notes, balance, loading: eventsLoading };
};
