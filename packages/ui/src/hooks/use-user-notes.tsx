import { Note } from "@/interfaces";
import { notesService } from "@/services/notes.service";
import { useBlockNumber } from "@starknet-react/core";
import { useEffect, useState } from "react";

export const useUserNotes = () => {
  const { data } = useBlockNumber({ refetchInterval: 10000 });

  const [notes, setNotes] = useState<Note[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);

    notesService
      .getNotes()
      .then(({ notesArray: notes }) => {
        setNotes(notes.filter((note) => note.value !== undefined));
      })
      .finally(() => setLoading(false));
  }, [data]);

  return { notes, loading };
};
