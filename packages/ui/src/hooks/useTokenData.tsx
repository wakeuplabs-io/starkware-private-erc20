import { useState } from "react";
import "./transfer.css";

const Transfer = () => {
  const [recipientAddress, setRecipientAddress] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);

  const handleTransfer = async () => {
    if (!recipientAddress || !recipientPublicKey || amount <= 0) {
      alert("Invalid recipient address, public key, or amount");
      return;
    }

    console.log("Transfer Data:", {
      recipientAddress,
      recipientPublicKey,
      amount,
    });

    alert("Transfer simulated successfully!");
  };

  return (
    <div className="transfer-container">
      <h2 className="transfer-title">Simulated Transfer</h2>

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
        onChange={(e) => setAmount(Number(e.target.value))}
      />

      <button className="transfer-button" onClick={handleTransfer}>
        Simulate Transfer
      </button>
    </div>
  );
};

export default Transfer;
