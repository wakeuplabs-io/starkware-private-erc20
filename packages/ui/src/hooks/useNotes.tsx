import { useEffect, useState } from "react";
import { useEvents } from "@/hooks/useEvents";
import { DecryptedOutput, Note } from "@/interfaces";
import { CipherService } from "@/services/cipher.service";
import { ZERO_BIG_INT } from "@/constants";
import { AccountService } from "@/services/account.service";
import { BarretenbergService } from "@/services/bb.service";

export const useNotes: () => {
  notes: Note[];
  balance: bigint;
  loading: boolean;
} = () => {
  const {
    commitments: commitmentEvents,
    nullifierHashes,
    isLoading: eventsLoading,
  } = useEvents();

  const [notes, setNotes] = useState<Note[]>([]);
  const [balance, setBalance] = useState<bigint>(ZERO_BIG_INT);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    const decryptNotes = async () => {
      if (!commitmentEvents.length) {
        setNotes([]);
        setBalance(ZERO_BIG_INT);
        setLoading(false);
        return;
      }

      try {
        const account = await AccountService.getAccount();
        const notesExpanded: Note[] = await Promise.all(
          commitmentEvents.map(async (commitmentEvent) => {
            try {
              const { commitment, encryptedOutput, index } = commitmentEvent;
              const nullifier = await BarretenbergService.generateNullifier(
                commitment,
                account.privateKey,
                index
              );
              const nullifierHash =
                await BarretenbergService.generateHash(nullifier);
              const isSpendable = nullifierHashes.includes(
                nullifierHash.toString(10)
              );
              if (!isSpendable) {
                const note: Note = {
                  commitment: commitment,
                  encryptedOutput: encryptedOutput,
                  index: index,
                };
                return note;
              }
              const decrypted: DecryptedOutput = JSON.parse(
                await CipherService.decrypt(
                  encryptedOutput,
                  account.publicKey,
                  account.privateKey
                )
              );

              const note: Note = {
                commitment: commitment,
                encryptedOutput: encryptedOutput,
                index: index,
                value: BigInt("0x" + decrypted.value),
                bliding: BigInt("0x" + decrypted.bliding),
              };
              return note;
            } catch (error) {
              const { commitment, encryptedOutput, index } = commitmentEvent;
              const note: Note = {
                commitment,
                encryptedOutput,
                index,
              };
              return note;
            }
          })
        );

        const balanceBigInt = notesExpanded
          .filter((note: Note) => note.value)
          .reduce((acc, note) => acc + note.value!, ZERO_BIG_INT);

        setNotes(notesExpanded);
        setBalance(balanceBigInt);
      } catch (error) {
        setNotes([]);
        setBalance(ZERO_BIG_INT);
      } finally {
        setLoading(false);
      }
    };

    decryptNotes();
  }, [commitmentEvents, nullifierHashes]);

  return { notes, balance, loading: eventsLoading || loading };
};
