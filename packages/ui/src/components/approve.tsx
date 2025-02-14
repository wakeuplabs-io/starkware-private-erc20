import { useApprove } from "@/hooks/use-approve";
import { useCallback, useState } from "react";
import { Button, buttonVariants } from "./ui/button";
import { Input } from "./ui/input";
import { QrCode } from "lucide-react";
import { IDetectedBarcode, Scanner } from "@yudiel/react-qr-scanner";
import { useToast } from "@/hooks/use-toast";
import { ToastAction } from "@radix-ui/react-toast";
import { buildExplorerUrl } from "@/lib/utils";
import { Checkbox } from "./ui/checkbox";
import { Label } from "./ui/label";

export const Approve: React.FC = () => {
  const { toast } = useToast();
  const { sendApprove, loading } = useApprove();
  const [shareViewingKey, setShareViewingKey] = useState<boolean>(false);

  const [scan, setScan] = useState(false);
  const [amount, setAmount] = useState("0");
  const [spender, setSpender] = useState({ address: "", publicKey: "" });

  const onApprove = useCallback(async () => {
    try {
      const txHash = await sendApprove({
        spender: {
          address: BigInt(spender.address),
          publicKey: BigInt(spender.publicKey),
        },
        amount: BigInt((parseFloat(amount) * 10 ** 6).toFixed(0)),
        shareViewingKey,
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
  }, [amount, spender, sendApprove]);

  const onScan = useCallback(
    (result: IDetectedBarcode[]) => {
      const { address, publicKey } = JSON.parse(result[0].rawValue);
      setSpender({ address, publicKey });

      setScan(false);
    },
    [spender, setScan]
  );

  return (
    <div className="flex flex-col p-6 bg-white rounded-3xl border border-primary">
      <h1 className="font-semibold mb-6">Approve</h1>

      {scan ? (
        <div>
          <Scanner onScan={onScan} />
        </div>
      ) : (
        <>
          <div className="space-y-8 mb-12">
            <div className="space-y-4 relative">
              <Button
                onClick={() => setScan(!scan)}
                size="icon"
                variant="ghost"
                className="absolute -top-2 right-0 h-6 w-6 text-blue-500 bg-transparent"
              >
                <QrCode />
              </Button>

              <div className="grid w-full items-center gap-2">
                <Label htmlFor="spender-address">Spender Address</Label>
                <Input
                  id="spender-address"
                  type="text"
                  placeholder="Spender Address"
                  value={spender.address}
                  onChange={(e) =>
                    setSpender({ ...spender, address: e.target.value })
                  }
                />
              </div>

              <div className="grid w-full items-center gap-2">
                <Label htmlFor="spender-public-key">Spender Public Key</Label>
                <Input
                  id="spender-public-key"
                  type="text"
                  placeholder="Spender Public Key"
                  value={spender.publicKey}
                  onChange={(e) =>
                    setSpender({ ...spender, publicKey: e.target.value })
                  }
                />
              </div>
            </div>

            <div className="space-y-4">
              <div className="grid w-full items-center gap-2">
                <Label htmlFor="amount">Amount</Label>
                <Input
                  id="amount"
                  type="text"
                  placeholder="Amount"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                />
              </div>

              <div className="flex items-center space-x-2">
                <Checkbox
                  id="viewing-key"
                  checked={shareViewingKey}
                  onCheckedChange={(e) => setShareViewingKey(e as boolean)}
                />
                <label
                  htmlFor="viewing-key"
                  className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                >
                  Share viewing key
                </label>
              </div>
            </div>
          </div>

          <Button className="w-full" onClick={onApprove} disabled={loading}>
            {loading ? "Approving..." : "Approve"}
          </Button>
        </>
      )}
    </div>
  );
};
