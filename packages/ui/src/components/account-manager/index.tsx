import { useState, useEffect } from "react";
import "./account-manager.css";
import SHA256 from "crypto-js/sha256";

const AccountManager = () => {
  const [secretAccount, setSecretAccount] = useState<string | null>(null);
  const [receiverAccounts, setReceiverAccounts] = useState<string[]>([]);
  const [newReceiver, setNewReceiver] = useState<string | null>(null);

  useEffect(() => {
    const savedSecret = localStorage.getItem("SecretAccount");
    const savedReceivers = JSON.parse(localStorage.getItem("ReceiverAccounts") || "[]");

    if (savedSecret) setSecretAccount(savedSecret);
    setReceiverAccounts(savedReceivers);
  }, []);

  const handleInitialize = () => {
    const secret = generateSecretAccount();
    setSecretAccount(secret);
    localStorage.setItem("SecretAccount", secret);
    alert("SecretAccount initialized!");
  };

  const handleGenerateReceiver = () => {
    if (!secretAccount) return;

    const newReceiverAddress = generateReceiverAddress(secretAccount, receiverAccounts.length);
    setReceiverAccounts((prev) => {
      const updatedReceivers = [...prev, newReceiverAddress];
      localStorage.setItem("ReceiverAccounts", JSON.stringify(updatedReceivers));
      return updatedReceivers;
    });
    setNewReceiver(newReceiverAddress);
  };

  return (
    <div className="account-manager-container">
      <h2 className="account-manager-title">Account Manager</h2>

      <button className="account-manager-button" onClick={handleInitialize} disabled={!!secretAccount}>
        Initialize Account
      </button>

      <button
        className="account-manager-button"
        onClick={handleGenerateReceiver}
        disabled={!secretAccount}
      >
        Generate Receive Address
      </button>

      {secretAccount && (
        <div className="account-manager-secret">
          <p><strong>SecretAccount:</strong> {secretAccount}</p>
        </div>
      )}

      {newReceiver && (
        <div className="account-manager-receiver">
          <p><strong>New Receiver Address:</strong> {newReceiver}</p>
        </div>
      )}

      <div className="account-manager-receivers-list">
        <h3>All Receiver Addresses:</h3>
        {receiverAccounts.map((address, index) => (
          <p key={index}>{address}</p>
        ))}
      </div>
    </div>
  );
};

function generateSecretAccount() {
  const array = new Uint8Array(32);
  window.crypto.getRandomValues(array);
  return Array.from(array, (byte) => byte.toString(16).padStart(2, "0")).join("");
}

function generateReceiverAddress(secretAccount: string, index: number) {
  const input = `${secretAccount}:${index}`;
  return SHA256(input).toString();
}

export default AccountManager;
