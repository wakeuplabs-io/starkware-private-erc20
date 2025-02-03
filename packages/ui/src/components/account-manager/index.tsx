import { useState, useEffect } from "react";
import "./account-manager.css";
import nacl from "tweetnacl";
import naclUtil from "tweetnacl-util";
import { ReceiverAccount } from "@/interfaces";
import { AccountService } from "@/services/account.service";

const AccountManager = () => {
  const [secretAccount, setSecretAccount] = useState<string | null>(null);
  const [receiverAccounts, setReceiverAccounts] = useState<ReceiverAccount[]>([]);
  const [newReceiver, setNewReceiver] = useState<ReceiverAccount>();

  const [ publicKey , setPublicKey ] = useState<string | null>(null);
  const [ secretKey , setSecretKey ] = useState<string | null>(null);

  useEffect(() => {
    const savedSecret = localStorage.getItem("SecretAccount");
    const savedReceivers = JSON.parse(localStorage.getItem("ReceiverAccounts") || "[]");
    const savedPublicKey = localStorage.getItem("PublicKey");
    const savedSecretKey = localStorage.getItem("SecretKey");

    if (savedSecret){ 
      AccountService.secretAccount = savedSecret;
      setSecretAccount(savedSecret);
    }
    setReceiverAccounts(savedReceivers);
    if (savedPublicKey) setPublicKey(savedPublicKey);
    if (savedSecretKey) setSecretKey(savedSecretKey);
  }, []);

  const handleInitialize = () => {
    const secret = AccountService.generateSecretAccount();
    setSecretAccount(secret);
    localStorage.setItem("SecretAccount", secret);

    generateKeyPair();
  };

  const handleGenerateReceiver = () => {
    if (!secretAccount) return;

    const newReceiverAddress = AccountService.generateReceiverAccount();
    setReceiverAccounts((prev) => {
      const updatedReceivers = [...prev, newReceiverAddress];
      localStorage.setItem("ReceiverAccounts", JSON.stringify(updatedReceivers));
      return updatedReceivers;
    });
    setNewReceiver(newReceiverAddress);
  };

  const generateKeyPair = () => {
    const keyPair = nacl.box.keyPair();
    setPublicKey(naclUtil.encodeBase64(keyPair.publicKey));
    setSecretKey(naclUtil.encodeBase64(keyPair.secretKey));
    localStorage.setItem("PublicKey", naclUtil.encodeBase64(keyPair.publicKey));
    localStorage.setItem("SecretKey", naclUtil.encodeBase64(keyPair.secretKey));
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
          <p><strong>New Receiver Address:</strong> {newReceiver.address}</p>
        </div>
      )}

      <div className="account-manager-receivers-list">
        <h3>All Receiver Addresses:</h3>
        {receiverAccounts.map((receiverAccount, index) => (
          <p key={index}>{receiverAccount.address}</p>
        ))}
      </div>
      <div className="account-manager-keys">
        <h3>Keys:</h3>
        {publicKey && <p><strong>Public Key:</strong> {publicKey}</p>}
        {secretKey && <p><strong>Secret Key:</strong> {secretKey}</p>}
      </div>
    </div>
  );
};


export default AccountManager;
