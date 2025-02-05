import { useNotes } from "@/hooks/useNotes";
import "./notes-list.css";

const NotesList = () => {
  const { balance } = useNotes();


  return (
    <div className="balance-card">
      <h3 className="balance-title">My Balance</h3>
      <p className="balance-amount">${balance.toString()}</p>
    </div>
  );
};

export default NotesList;
