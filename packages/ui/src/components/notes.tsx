import { cn, shortenString } from "@/lib/utils";
import { useUserNotes } from "@/hooks/use-user-notes";
import { useMemo } from "react";

export const Notes: React.FC<{ show: boolean }> = ({ show }) => {
  const { notes } = useUserNotes();

  const sortedNotes = useMemo(
    () => notes.sort((a, b) => parseInt((b.index - a.index).toString())),
    [notes]
  );

  return (
    <div className="flex flex-col px-6 py-4 bg-white rounded-3xl border border-gradient">
      <div className="flex justify-between items-center">
        <h1 className="font-semibold">Notes</h1>
      </div>

      {sortedNotes && show && (
        <ul className="divide-y border-t mt-4">
          {sortedNotes.length === 0 && (
            <li className="flex justify-between py-6 pr-2">
              <span className="text-muted-foreground">No notes</span>
            </li>
          )}

          {sortedNotes.map((note) => (
            <li
              key={note.commitment}
              className="flex justify-between py-6 pr-2"
            >
              <span
                className={cn({
                  "line-through": note.spent,
                })}
              >
                {shortenString(note.commitment.toString(16))} (
                {note.index.toString()})
              </span>
              <span
                className={cn({
                  "line-through": note.spent,
                })}
              >
                {note.value?.toString()}
              </span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};
