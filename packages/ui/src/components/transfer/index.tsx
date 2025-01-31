import { useTransfer } from "@/hooks/useTransfer";
import "./transfer.css";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const Transfer = ({ acir }: { acir: any }) => {
  const {
    recipientAddress,
    setRecipientAddress,
    recipientPublicKey,
    setRecipientPublicKey,
    amount,
    setAmount,
    proof,
    status,
    isLoading,
    // generateProof,
    sendTransfer,
    handleInputChange,
  } = useTransfer({ acir });

  return (
    <div className="transfer-container">
      <h2 className="transfer-title">Simulated Transfer</h2>

      <input
        className="transfer-input"
        type="text"
        placeholder="Recipient Address"
        value={recipientAddress}
        onChange={handleInputChange(setRecipientAddress)}
      />

      <input
        className="transfer-input"
        type="text"
        placeholder="Recipient Public Key"
        value={recipientPublicKey}
        onChange={handleInputChange(setRecipientPublicKey)}
      />

      <input
        className="transfer-input"
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={handleInputChange(setAmount)}
      />

      <button className="transfer-button" onClick={sendTransfer} disabled={isLoading}>
        {isLoading ? "Transferring..." : "Transfer "}
      </button>

      {proof && (
        <button className="transfer-button" onClick={sendTransfer}>
          Transfer
        </button>
      )}

      {status && (
        <div className={`transfer-status ${status.includes("Error") ? "error" : "success"}`}>
          {status}
        </div>
      )}
    </div>
  );
};

export default Transfer;
