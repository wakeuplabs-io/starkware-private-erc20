import { useNotes } from "@/hooks/useNotes";

const Balance = () => {
  const { balance } = useNotes();

  return (
    <div className="w-full border bg-muted p-4 rounded-md text-center">
      <h3 className="">My Balance</h3>
      <p className="mt-2 font-bold text-3xl">${balance.toString()}</p>
    </div>
  );
};

export default Balance;
