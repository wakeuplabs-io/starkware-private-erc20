import "./notes-list.css";
import { useNotes } from "@/hooks/useNotes";

const Balance = () => {
  const { balance } = useNotes();

  return (
    <div className="w-full border bg-muted p-4 rounded-md text-center">
      <h3 className="text-lg">My Balance</h3>
      <p className="balance-amount">${balance.toString()}</p>
    </div>
  );
};

export default Balance;
