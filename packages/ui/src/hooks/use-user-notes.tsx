import { Note } from "@/interfaces";
import { NotesService } from "@/services/notes.service";
import { useBlockNumber, useProvider } from "@starknet-react/core";
import { useEffect, useMemo, useState } from "react";
import { Provider } from "starknet";

export const useUserNotes = () => {
  const { data } = useBlockNumber({ refetchInterval: 10000 });
  const { provider } = useProvider() as { provider: Provider };

  const [notes, setNotes] = useState<Note[]>([]);
  const [loading, setLoading] = useState(false);

  const notesService = useMemo(() => {
    return new NotesService(provider);
  }, [provider]);

  useEffect(() => {
    setLoading(true);

    notesService
      .getNotes()
      .then(({ notesArray: notes }) => {
        setNotes(notes.filter((note) => note.value !== undefined));
      })
      .finally(() => setLoading(false));
  }, [data, notesService]);

  return { notes, loading };
};
