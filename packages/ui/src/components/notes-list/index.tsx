import { useNotes } from "@/hooks/useNotes";
import "./notes-list.css";
import { useMemo } from "react";

const NotesList = () => {
  const { balance } = useNotes();

  const balanceString = useMemo(() => {
    return (balance / 10n ** 6n).toString();
  }, [balance])

  return (
    <div className="balance-card">
      <h3 className="balance-title">My Balance</h3>
      <p className="balance-amount">${balance.toString()}</p>
    </div>
  );
};

export default NotesList;
