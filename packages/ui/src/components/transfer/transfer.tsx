import React, { useEffect, useState } from "react";
import { useTokenData } from "@/hooks/useTokenData";
import "./transfer.css";

const Transfer = () => {
  const [recipientAddress, setRecipientAddress] = useState("");
  const [amount, setAmount] = useState(0);
  const { sendTransfer, balance,status } = useTokenData();

  useEffect(() => {
    console.log({status})
  }
  ,[status])
  const handleTransfer = async () => {
    try {
      if (amount > 0 && recipientAddress) {
        // Convertir `amount` a bigint antes de enviarlo
        const amountBigInt = BigInt(amount);
        await sendTransfer(recipientAddress, amountBigInt);
      } else {
        alert("Invalid recipient address or amount");
      }
    } catch (error) {
      console.error("Transfer failed:", error);
      alert("Transfer failed");
    }
  };

  return (
    <div className="transfer-container">
      <h2 className="transfer-title">Transfer Tokens</h2>
      <p className="transfer-balance">Balance: {balance?.toString() || "Loading..."} Tokens</p>
      <input
        className="transfer-input"
        type="text"
        placeholder="Recipient Address"
        value={recipientAddress}
        onChange={(e) => setRecipientAddress(e.target.value)}
      />
      <input
        className="transfer-input"
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={(e) => setAmount(Number(e.target.value))}
      />
      <button className="transfer-button" onClick={handleTransfer}>
        Transfer
      </button>
    </div>
  );
};

export default Transfer;
