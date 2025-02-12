import { useTransfer } from "@/hooks/useTransfer";
import { useCallback, useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { QrCode } from "lucide-react";
import { IDetectedBarcode, Scanner } from "@yudiel/react-qr-scanner";

export const Transfer: React.FC = () => {
  const { sendTransfer, loading } = useTransfer();
  const [recipientAddress, setRecipientAddress] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);
  const [scan, setScan] = useState(false);

  const onTransfer = useCallback(async () => {
    sendTransfer({
      to: {
        address: BigInt(recipientAddress),
        publicKey: BigInt(recipientPublicKey),
      },
      amount: BigInt(amount),
    })
      .then(() => {
        window.alert("Transfer successful");
      })
      .catch((error) => {
        console.error(error);
        window.alert("Transfer failed");
      });
  }, [amount, recipientAddress, recipientPublicKey, sendTransfer]);

  const onScan = useCallback((result: IDetectedBarcode[]) => {
    const data = JSON.parse(result[0].rawValue);

    setRecipientAddress(data.address.startsWith("0x") ? data.address : `0x${data.address}`);
    setRecipientPublicKey(data.publicKey.startsWith("0x") ? data.publicKey : `0x${data.publicKey}`);
    setScan(false);
  }, [setRecipientAddress, setRecipientPublicKey, setScan]);

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
              value={recipientAddress}
              onChange={(e) => setRecipientAddress(e.target.value)}
            />

            <Input
              type="text"
              placeholder="Recipient Public Key"
              value={recipientPublicKey}
              onChange={(e) => setRecipientPublicKey(e.target.value)}
            />

            <Input
              type="number"
              placeholder="Amount"
              value={amount}
              onChange={(e) => setAmount(parseInt(e.target.value))}
            />
          </div>

          <Button className="w-full" onClick={onTransfer} disabled={loading}>
            {loading ? "Transferring..." : "Transfer "}
          </Button>
        </>
      )}
    </div>
  );
};
