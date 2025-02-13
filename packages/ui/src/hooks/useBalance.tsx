import { NotesService } from "@/services/notes.service";
import { useBlockNumber, useProvider } from "@starknet-react/core";
import { useEffect, useMemo, useState } from "react";
import { Provider } from "starknet";

export const useBalance = () => {
  const { data } = useBlockNumber({ refetchInterval: 10000 });
  const { provider } = useProvider() as { provider: Provider };

  const [balance, setBalance] = useState(0n);
  const [loading, setLoading] = useState(false);

  const notesService = useMemo(() => {
    return new NotesService(provider);
  }, [provider]);

  useEffect(() => {
    setLoading(true);

    notesService
      .getNotes()
      .then((notes) => {
        console.log("notes", notes)
        setBalance(notes.reduce((acc, note) => acc + (note.value && !note.spent ? note.value : 0n), 0n));
      })
      .finally(() => setLoading(false));
  }, [data, notesService]);

  return { balance, loading };
};
