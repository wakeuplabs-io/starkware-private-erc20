import { useTransfer } from "@/hooks/use-transfer";
import { useCallback, useEffect, useState } from "react";
import { Button, buttonVariants } from "./ui/button";
import { Input } from "./ui/input";
import { QrCode } from "lucide-react";
import { IDetectedBarcode, Scanner } from "@yudiel/react-qr-scanner";
import { useTransferFrom } from "@/hooks/use-transfer-from";
import { useToast } from "@/hooks/use-toast";
import { ToastAction } from "@radix-ui/react-toast";
import { buildExplorerUrl, formatHex } from "@/lib/utils";
import { Label } from "./ui/label";
import { useAccount } from "@/hooks/use-account";

export const Transfer: React.FC = () => {
  const { toast } = useToast();
  const { account } = useAccount();
  const { sendTransfer, loading: transferLoading } = useTransfer();
  const { sendTransferFrom, loading: transferFromLoading } = useTransferFrom();

  const [amount, setAmount] = useState("0");
  const [scan, setScan] = useState(false);
  const [transferFrom, setTransferFrom] = useState(false);
  const [from, setFrom] = useState({ address: "", publicKey: "" });
  const [to, setTo] = useState({ address: "", publicKey: "" });

  const onTransfer = useCallback(async () => {
    try {
      const amountBn = BigInt((parseFloat(amount) * 10 ** 6).toFixed(0));

      const txHash = transferFrom
        ? await sendTransferFrom({
            amount: amountBn,
            from: {
              address: BigInt(from.address),
              publicKey: BigInt(from.publicKey),
            },
            to: {
              address: BigInt(to.address),
              publicKey: BigInt(to.publicKey),
            },
          })
        : await sendTransfer({
            amount: amountBn,
            to: {
              address: BigInt(to.address),
              publicKey: BigInt(to.publicKey),
            },
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
  }, [amount, to, from, sendTransfer]);

  const onScan = useCallback(
    (result: IDetectedBarcode[]) => {
      const { address, publicKey } = JSON.parse(result[0].rawValue);
      setTo({ address, publicKey });

      setScan(false);
    },
    [setTo, setScan]
  );

  useEffect(() => {
    if (account && !transferFrom) {
      setFrom({
        address: formatHex(account.owner.address),
        publicKey: formatHex(account.viewer.publicKey),
      });
    }
  }, [account, transferFrom]);

  return (
    <div className="flex flex-col p-6 bg-white rounded-3xl border-gradient">
      <h1 className="font-semibold mb-6">Transfer</h1>

      {scan ? (
        <div>
          <Scanner onScan={onScan} />
        </div>
      ) : (
        <>
          <div className="grid gap-4 md:grid-cols-2 mb-8">
            <div className="space-y-4 relative">
              <div className="absolute top-2 right-0 ">
                {transferFrom ? (
                  <button
                    className="text-sm bg-transparent text-blue-500 hover:underline"
                    onClick={() => setTransferFrom(false)}
                  >
                    Reset
                  </button>
                ) : (
                  <button
                    className="text-sm bg-transparent text-blue-500 hover:underline"
                    onClick={() => setTransferFrom(true)}
                  >
                    Edit
                  </button>
                )}
              </div>

              <div className="grid w-full items-center gap-2">
                <Label htmlFor="from-address">{transferFrom ? "From Address" : "From My Address"}</Label>
                <Input
                  id="from-address"
                  type="text"
                  placeholder="0x..."
                  value={from.address}
                  disabled={!transferFrom}
                  onChange={(e) =>
                    setFrom({ ...from, address: e.target.value })
                  }
                />
              </div>

              <div className="grid w-full items-center gap-2">
                <Label htmlFor="from-public-key">{transferFrom ? "From Public Key" : "From My Public Key"}</Label>
                <Input
                  id="from-public-key"
                  type="text"
                  placeholder="0x..."
                  disabled={!transferFrom}
                  value={from.publicKey}
                  onChange={(e) =>
                    setFrom({ ...from, publicKey: e.target.value })
                  }
                />
              </div>
            </div>

            <div className="space-y-4 relative">
              <Button
                onClick={() => setScan(!scan)}
                size="icon"
                variant="ghost"
                className="absolute top-2 right-0 h-6 w-6 text-blue-500 bg-transparent"
              >
                <QrCode />
              </Button>

              <div className="grid w-full items-center gap-2">
                <Label htmlFor="to-address">To Address</Label>
                <Input
                  id="to-address"
                  placeholder="0x..."
                  type="text"
                  value={to.address}
                  onChange={(e) => setTo({ ...to, address: e.target.value })}
                />
              </div>

              <div className="grid w-full items-center gap-2">
                <Label htmlFor="to-public-key">To Public Key</Label>
                <Input
                  id="to-public-key"
                  placeholder="0x..."
                  type="text"
                  value={to.publicKey}
                  onChange={(e) => setTo({ ...to, publicKey: e.target.value })}
                />
              </div>
            </div>
          </div>

          <div className="grid gap-2 w-full mb-12">
            <Label htmlFor="amount">Amount</Label>
            <Input
              id="amount"
              type="text"
              placeholder="0.0"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
            />
          </div>

          <Button
            className="w-full"
            onClick={onTransfer}
            disabled={transferFromLoading || transferLoading}
          >
            {transferFromLoading || transferLoading
              ? "Transferring..."
              : "Transfer"}
          </Button>
        </>
      )}
    </div>
  );
};
