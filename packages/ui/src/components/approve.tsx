import { useApprove } from "@/hooks/use-approve";
import { useCallback, useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { QrCode } from "lucide-react";
import { IDetectedBarcode, Scanner } from "@yudiel/react-qr-scanner";
import { useToast } from "@/hooks/use-toast";
import { ToastAction } from "@radix-ui/react-toast";
import { buildExplorerUrl, shortenString } from "@/lib/utils";
import { Checkbox } from "./ui/checkbox";

export const Approve: React.FC = () => {
  const { toast } = useToast();
  const { sendApprove, loading } = useApprove();
  const [shareViewingKey, setShareViewingKey] = useState<boolean>(false);

  const [spender, setSpender] = useState({
    address: "",
    publicKey: "",
  });
  const [amount, setAmount] = useState("0");
  const [scan, setScan] = useState(false);

  const onApprove = useCallback(async () => {
    try {
      const txHash = await sendApprove({
        spender: {
          address: BigInt(spender.address),
          publicKey: BigInt(spender.publicKey),
        },
        amount: BigInt((parseFloat(amount) * 10 ** 6).toFixed(0)),
        shareViewingKey
      });

      toast({
        title: "Approve successful",
        description: `Transaction hash: ${shortenString(txHash)}`,
        action: (
          <ToastAction
            onClick={() => window.open(buildExplorerUrl(txHash), "_blank")}
            altText="View transaction"
          >
            View transaction
          </ToastAction>
        ),
      });
    } catch (e) {}
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
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-semibold">Approve</h1>
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
              placeholder="Spender Address"
              value={spender.address}
              onChange={(e) =>
                setSpender({ ...spender, address: e.target.value })
              }
            />

            <Input
              type="text"
              placeholder="Spender Public Key"
              value={spender.publicKey}
              onChange={(e) =>
                setSpender({ ...spender, publicKey: e.target.value })
              }
            />

            <Input
              type="text"
              placeholder="Amount"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
            />

            <div className="flex items-center space-x-2">
              <Checkbox id="viewing-key" checked={shareViewingKey} onCheckedChange={(e) => setShareViewingKey(e as boolean)} />
              <label
                htmlFor="viewing-key"
                className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              >
                Share viewing key
              </label>
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
