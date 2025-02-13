import { notesService } from "@/services/notes.service";
import { useBlockNumber } from "@starknet-react/core";
import { useEffect, useState } from "react";

export const useBalance = () => {
  const { data } = useBlockNumber({ refetchInterval: 10000 });

  const [balance, setBalance] = useState(0n);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);

    notesService
      .getNotes()
      .then(({ notesArray: notes }) => {
        setBalance(notes.reduce((acc, note) => acc + (note.value && !note.spent ? note.value : 0n), 0n));
      })
      .finally(() => setLoading(false));
  }, [data]);

  return { balance, loading };
};
