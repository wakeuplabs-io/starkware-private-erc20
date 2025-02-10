import { useTransfer } from "@/hooks/useTransfer";
import "./transfer.css";
import { useCallback, useState } from "react";
import { Button } from "../ui/button";
import { useAccount } from "@starknet-react/core";

const Transfer = () => {
  const { account } = useAccount();
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
    <div className="transfer-container">
      <h2 className="text-lg text-center">Transfer</h2>

      <input
        className="transfer-input"
        type="text"
        placeholder="Recipient Address"
        value={recipientAddress}
        onChange={(e) => setRecipientAddress(e.target.value)}
      />

      <input
        className="transfer-input"
        type="text"
        placeholder="Recipient Public Key"
        value={recipientPublicKey}
        onChange={(e) => setRecipientPublicKey(e.target.value)}
      />

      <input
        className="transfer-input"
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={(e) => setAmount(parseInt(e.target.value))}
      />

      <Button
        className="w-full mt-2"
        onClick={onTransfer}
        disabled={loading || !account}
      >
        {!account ? "Connect Wallet" : loading ? "Loading..." : "Transfer "}
      </Button>
    </div>
  );
};

export default Transfer;
