import { useTransfer } from "@/hooks/useTransfer";
import { useCallback, useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";

export const Transfer: React.FC = () => {
  const { sendTransfer, loading } = useTransfer();
  const [recipientAddress, setRecipientAddress] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);

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

  return (
    <div className="flex flex-col p-6 bg-white rounded-3xl border border-primary">
      <h1 className="mb-8 font-semibold">Transfer</h1>

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
    </div>
  );
};

