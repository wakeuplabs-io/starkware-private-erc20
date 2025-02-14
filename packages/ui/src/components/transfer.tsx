import { useTransfer } from "@/hooks/use-transfer";
import { useCallback, useState } from "react";
import { Button, buttonVariants } from "./ui/button";
import { Input } from "./ui/input";
import { QrCode, WalletIcon } from "lucide-react";
import { IDetectedBarcode, Scanner } from "@yudiel/react-qr-scanner";
import { useTransferFrom } from "@/hooks/use-transfer-from";
import { useToast } from "@/hooks/use-toast";
import { ToastAction } from "@radix-ui/react-toast";
import { buildExplorerUrl } from "@/lib/utils";

export const Transfer: React.FC = () => {
  const { toast } = useToast();
  const { sendTransfer, loading: transferLoading } = useTransfer();
  const { sendTransferFrom, loading: transferFromLoading } = useTransferFrom();
  const [from, setFrom] = useState({
    address: "",
    publicKey: "",
  });
  const [to, setTo] = useState({
    address: "",
    publicKey: "",
  });

  const [amount, setAmount] = useState("0");
  const [scan, setScan] = useState(false);
  const [transferFrom, setTransferFrom] = useState(false);

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

  return (
    <div className="flex flex-col p-6 bg-white rounded-3xl border border-primary">
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-semibold">Transfer</h1>
        <Button onClick={() => setScan(!scan)} size="icon">
          <QrCode />
        </Button>
      </div>

      {scan ? (
        <div>
          <Scanner onScan={onScan} />
        </div>
      ) : (
        <>
          <div className="space-y-4 mb-12">
            <Input
              type="text"
              placeholder="Recipient Address"
              value={to.address}
              onChange={(e) => setTo({ ...to, address: e.target.value })}
            />

            <Input
              type="text"
              placeholder="Recipient Public Key"
              value={to.publicKey}
              onChange={(e) => setTo({ ...to, publicKey: e.target.value })}
            />

            <Input
              type="text"
              placeholder="Amount"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
            />

            {transferFrom && (
              <>
                <Input
                  type="text"
                  placeholder="Sender Address"
                  value={from.address}
                  onChange={(e) =>
                    setFrom({ ...from, address: e.target.value })
                  }
                />

                <Input
                  type="text"
                  placeholder="Sender Public Key"
                  value={from.publicKey}
                  onChange={(e) =>
                    setFrom({ ...from, publicKey: e.target.value })
                  }
                />
              </>
            )}
          </div>

          <div className="flex gap-4">
            <Button
              className="w-full"
              onClick={onTransfer}
              disabled={transferFromLoading || transferLoading}
            >
              {transferFromLoading || transferLoading
                ? "Transferring..."
                : "Transfer"}
            </Button>
            <Button onClick={() => setTransferFrom(!transferFrom)}>
              <WalletIcon />
            </Button>
          </div>
        </>
      )}
    </div>
  );
};
