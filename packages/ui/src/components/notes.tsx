import { Eye, EyeClosed } from "lucide-react";
import { Button } from "./ui/button";
import { cn, shortenAddress } from "@/lib/utils";
import { useUserNotes } from "@/hooks/use-user-notes";
import { useDeposit } from "@/hooks/use-deposit";
import { useCallback, useMemo, useState } from "react";
import { Input } from "./ui/input";
import { toast } from "@/hooks/use-toast";
import { ToastAction } from "@radix-ui/react-toast";

export const Notes: React.FC = () => {
  const { notes } = useUserNotes();
  const { sendDeposit, loading: depositLoading } = useDeposit();

  const [show, setShow] = useState(false);
  const [amountToDeposit, setAmountToDeposit] = useState("");

  const sortedNotes = useMemo(
    () => notes.sort((a, b) => parseInt((b.index - a.index).toString())),
    [notes]
  );

  const onDeposit = useCallback(async () => {
    try {
      const amountBn = BigInt((parseFloat(amountToDeposit) * 10 ** 6).toFixed(0));

      const txHash = await sendDeposit({
        amount: amountBn,
      });

      toast({
        title: "Transfer successful",
        description: `Transaction hash: ${txHash}`,
        action: (
          <ToastAction
            onClick={() =>
              window.open(`https://sepolia.voyager.online/tx/${txHash}`, "_blank")
            }
            altText="View transaction"
          >
            View transaction
          </ToastAction>
        ),
      });
    } catch (e) {
      toast({
        title: "Transfer failed",
        description: (e as Error).message,
        variant: "destructive",
      });
    }
  }, [sendDeposit, amountToDeposit]);

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col px-6 py-2 bg-white rounded-3xl border border-primary">
        <div className="flex justify-between items-center py-2 gap-2">
          <Input
            type="text"
            placeholder="Amount"
            value={amountToDeposit}
            onChange={(e) => setAmountToDeposit(e.target.value)}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-lg"
          />
          <Button
            className="px-6 py-2 bg-primary text-white font-semibold rounded-lg min-w-[120px]"
            onClick={() => onDeposit()}
          >
            {depositLoading ? "Depositing..." : "Deposit"}
          </Button>
        </div>
      </div>



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
    </div>

  );
};
