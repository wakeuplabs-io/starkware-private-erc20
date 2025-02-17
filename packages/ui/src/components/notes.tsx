import { Plus, ArrowLeft } from "lucide-react";
import { Button, buttonVariants } from "./ui/button";
import {
  buildExplorerUrl,
  cn,
  formatTokenAmount,
  shortenString,
} from "@/lib/utils";
import { useUserNotes } from "@/hooks/use-user-notes";
import { useState, useMemo, useCallback } from "react";
import { Input } from "./ui/input";
import { toast } from "@/hooks/use-toast";
import { ToastAction } from "@radix-ui/react-toast";
import { useDeposit } from "@/hooks/use-deposit";
import { ENG_TO_ETH_RATIO } from "@/shared/config/constants";
import { Label } from "./ui/label";

export const Notes: React.FC<{ show: boolean }> = ({ show }) => {
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

  const ethAmount: bigint = useMemo(() => {
    try {
      if (!amount) {
        return 0n;
      }

      const amountBn = BigInt((parseFloat(amount) * 10 ** 6).toFixed(0));

      return BigInt(amountBn) * ENG_TO_ETH_RATIO;
    } catch (e) {
      return 0n;
    }
  }, [amount]);

  return (
    <div className="flex flex-col gap-4">
      {showBuy ? (
        <div className="flex flex-col p-6 bg-white rounded-3xl border border-primary">
          <h1 className="font-semibold mb-6">Buy</h1>

          <div className="flex flex-col gap-2 pb-36">
            <Label htmlFor="amount">Amount</Label>

            <div className="relative">
              <Input
                id="amount"
                type="text"
                placeholder="0.00"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                className="h-[60px] text-xl flex-1 pl-4 pr-[140px]"
              />
              <span className="text-muted-foreground text-sm text-nowrap absolute right-2 top-1/2 -translate-y-1/2">
                ~ {formatTokenAmount(ethAmount, 18n, 8)} ETH
              </span>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <Button
              size="icon"
              variant="outline"
              onClick={() => setShowBuy(false)}
            >
              <ArrowLeft size={20} />
            </Button>

            <Button className="w-full" onClick={onDeposit}>
              {depositLoading ? "Buying..." : "Buy"}
            </Button>
          </div>
        </div>
      ) : (
        <div className="flex flex-col px-6 py-2 bg-white rounded-3xl border border-primary">
          <div className="flex justify-between items-center py-2">
            <h1 className="font-semibold">Notes</h1>
            <Button
              onClick={() => setShowBuy(true)}
              variant="outline"
              size="sm"
              className="rounded-full"
            >
              <Plus className="h-4 text-black" /> Buy
            </Button>
          </div>

          {show && (
            <ul className="divide-y border-t">
              {sortedNotes.map((note) => (
                <li
                  key={note.commitment}
                  className="flex justify-between py-6 pr-2"
                >
                  <span className={cn({ "line-through": note.spent })}>
                    {shortenString(note.commitment.toString(16))} (
                    {note.index.toString()})
                  </span>
                  <span className={cn({ "line-through": note.spent })}>
                    {note.value?.toString()}
                  </span>
                </li>
              ))}

              {sortedNotes.length === 0 && (
                <li className="flex justify-between py-6 pr-2">
                  <span className="text-muted-foreground">No notes</span>
                </li>
              )}
            </ul>
          )}
        </div>
      )}
    </div>
  );
};
