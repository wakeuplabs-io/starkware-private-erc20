import { useEffect, useState, useCallback, useRef } from "react";
import { useEvents } from "@/hooks/useEvents";
import { DecryptedOutput, Note } from "@/interfaces";
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
  const lastCommitmentCountRef = useRef<number>(0);

  const fetchNotes = useCallback(async () => {
    try {
      if (!commitmentEvents.length) {
        setNotes([]);
        setBalance(ZERO_BIG_INT);
        setLoading(false);
        return;
      }
      console.log("COMMIEMTNE LEGNTH",commitmentEvents);
      const account = await AccountService.getAccount();
      const notesExpanded: Note[] = await Promise.all(
        commitmentEvents.map(async (commitmentEvent) => {
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

      setNotes(notesExpanded);
      setBalance(balanceBigInt);
    } catch (error) {
      setNotes([]);
      setBalance(ZERO_BIG_INT);
    } finally {
      setLoading(false);
    }
  }, [commitmentEvents, nullifierHashes]);

  useEffect(() => {
    const loadCachedNotes = async () => {
      try {
        const cachedNotes = await NoteCacheService.getMyNotes();
        const cachedCommitments = await NoteCacheService.getCommitments();
        console.log({cachedCommitments});

        if (cachedNotes && cachedCommitments.length === commitmentEvents.length) {
          setNotes(cachedNotes);
          setBalance(
            cachedNotes
              .filter((note) => note.value)
              .reduce((acc, note) => acc + note.value!, ZERO_BIG_INT)
          );
          setLoading(false);
        } else if (commitmentEvents.length !== lastCommitmentCountRef.current) {
          lastCommitmentCountRef.current = commitmentEvents.length;
          fetchNotes();
        }
      } catch (error) {
        console.error("Error loading cached notes:", error);
        fetchNotes();
      }
    };

    loadCachedNotes();
  }, [commitmentEvents, fetchNotes]);

  return { notes, balance, loading: eventsLoading || loading };
};
