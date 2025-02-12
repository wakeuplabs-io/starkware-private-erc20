import { Eye, EyeClosed } from "lucide-react";
import { Button } from "./ui/button";
import { cn, shortenAddress } from "@/lib/utils";
import { useUserNotes } from "@/hooks/useUserNotes";
import { useMemo, useState } from "react";

export const Notes: React.FC = () => {
  const { notes } = useUserNotes();
  const [show, setShow] = useState(false);

  const sortedNotes = useMemo(
    () => notes.sort((a, b) => parseInt((b.index - a.index).toString())),
    [notes]
  );

  return (
    <div className="flex flex-col px-6 py-2 bg-white rounded-3xl border border-primary">
      <div className="flex justify-between items-center py-2">
        <h1 className="font-semibold">Notes</h1>
        <Button
          size="icon"
          variant="ghost"
          className="bg-white"
          onClick={() => setShow(!show)}
        >
          {show ? <Eye /> : <EyeClosed />}
        </Button>
      </div>

      {sortedNotes && show && (
        <ul className="divide-y border-t">
          {sortedNotes.map((note) => (
            <li className="flex justify-between py-6 pr-2">
              <span
                className={cn({
                  "line-through": note.spent,
                })}
              >
                {shortenAddress(note.commitment.toString(16))} (
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
