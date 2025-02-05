import { useNotes } from "@/hooks/useNotes";
import "./notes-list.css";

const NotesList = () => {
  const { notes, error } = useNotes();

  // Calcular el balance sumando los valores de las notas
  const balance = notes.reduce((acc, note) => acc + note.value, 0);

  if (error) return <div className="notes-message">Error: {error}</div>;

  return (
    <div className="balance-card">
      <h3 className="balance-title">My Balance</h3>
      <p className="balance-amount">${balance}</p>
    </div>
  );
};

export default NotesList;
