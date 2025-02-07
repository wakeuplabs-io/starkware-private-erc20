import { useState, useEffect } from "react";
import { AccountService } from "@/services/account.service";

const AccountManager = () => {
  const [publicKey, setPublicKey] = useState("");
  const [privateKey, setPrivateKey] = useState("");
  const [address, setAddress] = useState("");

  useEffect(() => {
    async function fetchAccount() {
      const account = await AccountService.getAccount();

      setPublicKey(account.publicKey.toString(16));
      setPrivateKey(account.privateKey.toString(16));
      setAddress(account.address.toString(16));
    }

    fetchAccount();
  }, []);

  return (
    <div className="border rounded-md bg-muted p-4">
      <div>
        {privateKey && (
          <p>
            <strong>Address:</strong> 0x{address}
          </p>
        )}
        {publicKey && (
          <p>
            <strong>Public Key:</strong> 0x{publicKey}
          </p>
        )}
        {privateKey && (
          <p>
            <strong>Private Key:</strong> 0x{privateKey}
          </p>
        )}
      </div>
    </div>
  );
};

export default AccountManager;
