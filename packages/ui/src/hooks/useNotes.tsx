import { useEffect, useState } from "react";
import { useEvents } from "@/hooks/useEvents";
import { DecryptedOutput, Note } from "@/interfaces";
import { CipherService } from "@/services/cipher.service";
import { ZERO_BIG_INT } from "@/constants";
import { AccountService } from "@/services/account.service";

export const useNotes: () => {
  notes: Note[];
  balance: bigint;
  loading: boolean;
} = () => {
  const { commitments, isLoading: eventsLoading } = useEvents();

  const [notes, setNotes] = useState<Note[]>([]);
  const [balance, setBalance] = useState<bigint>(ZERO_BIG_INT);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    const decryptNotes = async () => {
      if (!commitments.length) {
        setNotes([]);
        setBalance(ZERO_BIG_INT);
        setLoading(false);
        return;
      }

      try {
        const notesExpanded: Note[] = await Promise.all(
          commitments.map(async (commitment) => {
            try {
              const account = await AccountService.getAccount();
              const decrypted: DecryptedOutput = JSON.parse(
                await CipherService.decrypt(
                  commitment.encryptedOutput,
                  account.publicKey,
                  account.publicKey
                )
              );

              return {
                commitment: commitment.commitment,
                encryptedOutput: commitment.encryptedOutput,
                index: commitment.index,
                value: decrypted.value,
                blinding: decrypted.bliding,
              };
            } catch (error) {
              return {
                commitment: commitment.commitment,
                encryptedOutput: commitment.encryptedOutput,
                index: commitment.index,
              };
            }
          })
        );

        setNotes(notesExpanded);
        setBalance(
          notesExpanded
            .filter((note: Note) => note.value)
            .reduce((acc, note) => acc + note.value!, ZERO_BIG_INT)
        );
      } catch (error) {
        console.error("Error decrypting notes:", error);
        setNotes([]);
        setBalance(ZERO_BIG_INT);
      } finally {
        setLoading(false);
      }
    };

    decryptNotes();
  }, [commitments]);

  return { notes, balance, loading: eventsLoading || loading };
};
