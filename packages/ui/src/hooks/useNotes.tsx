import naclUtil from "tweetnacl-util";
import { useMemo } from "react";
import { useEvents } from "@/hooks/useEvents";
import { NoteExpanded, ReceiverAccount } from "@/interfaces";
import { BarretenbergService } from "@/services/bb.service";
import { CipherService } from "@/services/cipher.service";

export const useNotes = () => {
  const {
    commitments,
    nullifierHashes,
    isLoading: eventsLoading,
  } = useEvents();

  const { notes, balance } = useMemo(() => {
    try {
      if (!commitments.length) {
        throw new Error("No commitments");
      }

      const publicKey = naclUtil.decodeBase64(
        localStorage.getItem("PublicKey")!
      );
      const secretKey = naclUtil.decodeBase64(
        localStorage.getItem("SecretKey")!
      );
      const storedReceiverAddresses: ReceiverAccount[] = JSON.parse(
        localStorage.getItem("ReceiverAccounts") || "[]"
      );

      const notes = commitments
        .map((commitment) => {
          const decrypted = CipherService.decryptNote(
            commitment.encryptedValue,
            secretKey,
            publicKey
          );
          
          const nullifier: string =
            storedReceiverAddresses.find(
              (receiver) => receiver.address === commitment.address
            )?.nullifier || "unknown nullifier";

          const nullifierHash = BarretenbergService.generateHash(nullifier);
          const note: NoteExpanded = {
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
