import { useTransfer } from "@/hooks/useTransfer";
import "./transfer.css";

const Transfer = () => {
  const {
    publicRecipientAccount,
    setPublicRecipientAccount,
    recipientPublicKey,
    setRecipientPublicKey,
    amount,
    setAmount,
    status,
    isLoading,
    sendTransfer,
    handleInputChange,
  } = useTransfer();

  return (
    <div className="transfer-container">
      <h2 className="transfer-title">Simulated Transfer</h2>

      <input
        className="transfer-input"
        type="text"
        placeholder="Recipient Address"
        value={publicRecipientAccount}
        onChange={handleInputChange(setPublicRecipientAccount)}
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


      {status && (
        <div className={`transfer-status ${status.includes("Error") ? "error" : "success"}`}>
          {status}
        </div>
      )}
    </div>
  );
};

export default Transfer;
