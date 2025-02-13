import { useTransfer } from "@/hooks/useTransfer";
import { useCallback, useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { QrCode } from "lucide-react";
import { IDetectedBarcode, Scanner } from "@yudiel/react-qr-scanner";
import { useTransferFrom } from "@/hooks/useTransferFrom";

export const Transfer: React.FC = () => {
  const { sendTransfer, loading } = useTransfer();
  const { sendTransferFrom } = useTransferFrom();
  const [recipientAddress, setRecipientAddress] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState("0");
  const [scan, setScan] = useState(false);

  const onTransfer = useCallback(async () => {
    sendTransferFrom({
      from: {
        address: BigInt("0xf4280fa36dd274233822111013be2d770e02332ac2766ae093aa25ee33a2d31"),
        publicKey: BigInt("0x9fe40de6a38adf7cb7ed7afbd20a65d068682ab1090fd6274a44b10be0cfad10"),
      },
      to: {
        address: BigInt("0x2b37f11720bc94c3c683985e4837d8796cc202dd99cff285fee9035250a7097c"),
        publicKey: BigInt("0xb8b2f1337369cd0dfdbd36b4d33e66c58d587a9ad77c2f3cf469d9109f91655e"),
      },
      amount: 1000000n,
    });
    // sendTransfer({
    //   to: {
    //     address: BigInt(recipientAddress),
    //     publicKey: BigInt(recipientPublicKey),
    //   },
    //   amount: BigInt((parseFloat(amount) * 10**6).toFixed(0)),
    // })
    //   .then(() => {
    //     window.alert("Transfer successful");
    //   })
    //   .catch((error) => {
    //     console.error(error);
    //     window.alert("Transfer failed");
    //   });
  }, [amount, recipientAddress, recipientPublicKey, sendTransfer]);

  const onScan = useCallback(
    (result: IDetectedBarcode[]) => {
      const data = JSON.parse(result[0].rawValue);

      setRecipientAddress(
        data.address.startsWith("0x") ? data.address : `0x${data.address}`
      );
      setRecipientPublicKey(
        data.publicKey.startsWith("0x") ? data.publicKey : `0x${data.publicKey}`
      );
      setScan(false);
    },
    [setRecipientAddress, setRecipientPublicKey, setScan]
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
              type="text"
              placeholder="Amount"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
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
