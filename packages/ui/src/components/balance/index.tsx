import { useNotes } from "@/hooks/useNotes";
import "./notes-list.css";
import { useMemo } from "react";

const Balance = () => {
  const { balance } = useNotes();

  const balanceString = useMemo(() => {
    return (balance / 10n ** 6n).toString();
  }, [balance])

  return (
    <div className="w-full border bg-muted p-4 rounded-md text-center">
      <h3 className="text-lg">My Balance</h3>
      <p className="balance-amount">${balance.toString()}</p>
    </div>
  );
};

export default Balance;
