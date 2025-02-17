import { Plus, ArrowLeft } from "lucide-react";
import { Button, buttonVariants } from "./ui/button";
import { buildExplorerUrl, cn, formatTokenAmount, shortenString } from "@/lib/utils";
import { useUserNotes } from "@/hooks/use-user-notes";
import { useState, useMemo, useCallback } from "react";
import { Input } from "./ui/input";
import { toast } from "@/hooks/use-toast";
import { ToastAction } from "@radix-ui/react-toast";
import { useDeposit } from "@/hooks/use-deposit";
import { PRIVATE_TO_PUBLIC_RATIO } from "@/shared/config/constants";

interface NotesProps {
  showBalance: boolean;
}

export const Notes: React.FC<NotesProps> = ({ showBalance }: NotesProps) => {
  const { notes } = useUserNotes();
  const [showBuy, setShowBuy] = useState(false);
  const [amount, setAmount] = useState("");
  const { sendDeposit, loading: depositLoading } = useDeposit();

  const sortedNotes = useMemo(
    () => notes.sort((a, b) => parseInt((b.index - a.index).toString())),
    [notes]
  );

  const onDeposit = useCallback(async () => {
    try {
      const amountBn = BigInt((parseFloat(amount) * 10 ** 6).toFixed(0));

      const txHash = await sendDeposit({
        amount: amountBn,
      });

      toast({
        title: "Transaction sent successfully",
        action: (
          <ToastAction
            className={buttonVariants({ variant: "link", size: "sm" })}
            onClick={() => window.open(buildExplorerUrl(txHash), "_blank")}
            altText="View transaction"
          >
            View transaction
          </ToastAction>
        ),
      });
    } catch (e) {
      toast({
        title: "Something went wrong",
        description: (e as Error).message,
        variant: "destructive",
      });
    }
  }, [amount]);

  const ethAmount = useMemo(() => {
    return BigInt(amount) * PRIVATE_TO_PUBLIC_RATIO
  }, [amount]);

  return (
    <div className="flex flex-col gap-4">
      {showBuy ? (
        <div className="flex flex-col px-6 py-6 bg-white rounded-3xl border border-primary">
          <div className="flex justify-between items-center pb-4">
            <h1 className="text-lg font-semibold">Buy Enigma</h1>
          </div>
          <div className="flex flex-col gap-2 pb-20">
            <label className="text-sm text-gray-500">Amount</label>
            <div className="flex items-center border border-gray-300 rounded-lg">
              <Input
                type="text"
                placeholder="0.00"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                className="border-none"
              />
              <span className="text-gray-500 text-sm">~ {formatTokenAmount(ethAmount, 18n, 8)} ETH</span>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <button
              onClick={() => setShowBuy(false)}
              className="p-3 border border-gray-300 rounded-lg hover:bg-gray-200"
            >
              <ArrowLeft size={20} />
            </button>

            <Button
              className="flex-1 bg-[#0B0B51] text-white font-semibold text-lg py-3 rounded-lg"
              onClick={onDeposit}
            >
              {depositLoading
                ? "Buying..."
                : "Buy"}
            </Button>
          </div>
        </div>
      ) : (
        <div className="flex flex-col px-6 py-2 bg-white rounded-3xl border border-primary">
          <div className="flex justify-between items-center py-2">
            <h1 className="font-semibold">Notes</h1>
            <Button
              onClick={() => setShowBuy(true)}
              className={cn(
                "h-9 px-4 text-sm border border-input hover:bg-accent bg-transparent rounded-lg border-primary flex items-center gap-1 text-black"
              )}
            >
              <Plus className="h-4 text-black" /> Buy
            </Button>
          </div>

          {sortedNotes.length > 0 ? (
            <ul className="divide-y border-t">
              {sortedNotes.map((note) => (
                <li key={note.commitment} className="flex justify-between py-6 pr-2">
                  <span className={cn({ "line-through": note.spent })}>
                    {shortenString(note.commitment.toString(16))} ({note.index.toString()})
                  </span>
                  <span className={cn({ "line-through": note.spent })}>
                    {showBalance ? note.value?.toString() : "****"}
                  </span>
                </li>
              ))}
            </ul>
          ) : (
            <li className="flex justify-between py-6 pr-2">
              <span className="text-muted-foreground">No notes</span>
            </li>
          )}
        </div>
      )}
    </div>
  );
};
