import { useState, useCallback } from "react";
import { Button } from "../ui/button";
import { useTransfer } from "@/hooks/useTransfer";
import { useAccount } from "@starknet-react/core";
import { useTransferFrom } from "@/hooks/useTransferFrom";
import "./transfer.css";

const Transfer = () => {
  const { account } = useAccount();
  const { sendTransfer, loading: loadingTransfer } = useTransfer();
  const { sendTransferFrom, loading: loadingTransferFrom } = useTransferFrom();

  const [useTransferFromMode, setUseTransferFromMode] = useState(false);

  const [recipientAddress, setRecipientAddress] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);

  const [senderAddress, setSenderAddress] = useState("");
  const [senderPublicKey, setSenderPublicKey] = useState("");

  const onSubmit = useCallback(async () => {
    if (useTransferFromMode) {
      await sendTransferFrom({
        from: {
          address: BigInt(senderAddress),
          publicKey: BigInt(senderPublicKey),
        },
        to: {
          address: BigInt(recipientAddress),
          publicKey: BigInt(recipientPublicKey),
        },
        amount: BigInt(amount),
      });
    } else {
      await sendTransfer({
        to: {
          address: BigInt(recipientAddress),
          publicKey: BigInt(recipientPublicKey),
        },
        amount: BigInt(amount),
      });
    }
  }, [
    amount,
    recipientAddress,
    recipientPublicKey,
    senderAddress,
    senderPublicKey,
    sendTransfer,
    sendTransferFrom,
    useTransferFromMode,
  ]);

  return (
    <div className="transfer-container">
      <h2 className="text-lg text-center">Transfer</h2>

      <label className="transfer-checkbox">
        <input
          type="checkbox"
          checked={useTransferFromMode}
          onChange={(e) => setUseTransferFromMode(e.target.checked)}
        />
        Use TransferFrom
      </label>

      {useTransferFromMode && (
        <>
          <input
            className="transfer-input"
            type="text"
            placeholder="Sender Address"
            value={senderAddress}
            onChange={(e) => setSenderAddress(e.target.value)}
          />

          <input
            className="transfer-input"
            type="text"
            placeholder="Sender Public Key"
            value={senderPublicKey}
            onChange={(e) => setSenderPublicKey(e.target.value)}
          />
        </>
      )}

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
        onClick={onSubmit}
        disabled={loadingTransfer || loadingTransferFrom || !account}
      >
        {!account ? "Connect Wallet" : (loadingTransfer || loadingTransferFrom) ? "Loading..." : useTransferFromMode ? "Transfer From" : "Transfer"}
      </Button>
    </div>
  );
};

export default Transfer;
