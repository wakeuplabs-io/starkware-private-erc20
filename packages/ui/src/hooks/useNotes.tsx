import { useEffect, useState, useCallback } from "react";
import { useEvents } from "@/hooks/useEvents";
import { CommitmentEvent, DecryptedOutput, Note } from "@/interfaces";
import { CipherService } from "@/services/cipher.service";
import { ZERO_BIG_INT } from "@/constants";
import { AccountService } from "@/services/account.service";
import { BarretenbergService } from "@/services/bb.service";
import NoteCacheService from "@/services/note.cache.service";

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

  const fetchNotes = useCallback(async (newCommitments: CommitmentEvent[]) => {
    try {
      const account = await AccountService.getAccount();
      const notesExpanded: Note[] = await Promise.all(
        newCommitments.map(async (commitmentEvent) => {
          try {
            const { commitment, encryptedOutput, index }: Note =
              commitmentEvent;
            const nullifier = await BarretenbergService.generateNullifier(
              commitment,
              account.privateKey,
              index
            );
            const nullifierHash =
              await BarretenbergService.generateHash(nullifier);
            const isNotSpendable = nullifierHashes.includes(
              nullifierHash.toString(10)
            );

            if (isNotSpendable) {
              return { commitment, encryptedOutput, index };
            }

            const decrypted: DecryptedOutput = JSON.parse(
              await CipherService.decrypt(
                encryptedOutput,
                account.publicKey,
                account.privateKey
              )
            );
            return {
              commitment,
              encryptedOutput,
              index,
              value: BigInt("0x" + decrypted.value),
              bliding: BigInt("0x" + decrypted.bliding),
              nullifierHash
            };
          } catch (error) {
            const { commitment, encryptedOutput, index }: Note =
              commitmentEvent;
            return { commitment, encryptedOutput, index };
          }
        })
      );
      const balanceBigInt = notesExpanded
        .filter((note) => note.value)
        .reduce((acc, note) => acc + note.value!, ZERO_BIG_INT);
      await NoteCacheService.setMyNotes(
        notesExpanded.filter((note) => note.value)
      );
      await NoteCacheService.setNotes(
        notesExpanded
      );

      setNotes(notesExpanded);
      setBalance(balanceBigInt);
    } catch (error) {
      setNotes([]);
      setBalance(ZERO_BIG_INT);
    } finally {
      setLoading(false);
    }
  }, [nullifierHashes]);

  useEffect(() => {
    const loadCachedNotes = async () => {
      try {
        const myNotes = await NoteCacheService.getMyNotes();
        const cachedNotes = await NoteCacheService.getNotes();
        const newCommitments = commitmentEvents.filter(
          (commitmentEvent) => !cachedNotes.some((note) => commitmentEvent.commitment === note.commitment)
        );

        console.log({myNotes});
        console.log({newCommitments});
        console.log({commitmentEvents});
        console.log({cachedNotes});
        console.log("------");

        if (myNotes && newCommitments.length === 0) {
          const spendableNotes = myNotes.filter(note=> !nullifierHashes.includes(note.nullifierHash?.toString(16)|| ""));
          setNotes(myNotes);
          setBalance(
            spendableNotes 
              .reduce((acc, note) => acc + note.value!, ZERO_BIG_INT)
          );
          setLoading(false);
        } else {
          fetchNotes(newCommitments);
        }
      } catch (error) {
        console.error("Error loading cached notes:", error);
      }
    };

    loadCachedNotes();
  }, [nullifierHashes, commitmentEvents, fetchNotes]);

  return { notes, balance, loading: eventsLoading || loading };
};
