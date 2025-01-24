import { useWallet } from "@/shared/context/wallet-context";

const ConnectButton = () => {
  const { isConnected, account, connectWallet, disconnectWallet } = useWallet();

  return (
    <div>
      {isConnected ? (
        <div>
          <p>Connected to: {account?.address}</p>
          <button onClick={disconnectWallet}>Disconnect</button>
        </div>
      ) : (
        <button onClick={connectWallet}>Connect Wallet</button>
      )}
    </div>
  );
};

export default ConnectButton;
