import { StarknetkitConnector, useStarknetkitConnectModal } from "starknetkit";
import { useAccount, useConnect, useDisconnect } from "@starknet-react/core";

const ConnectButton = () => {
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const { address } = useAccount();
  const { starknetkitConnectModal } = useStarknetkitConnectModal({
    connectors: connectors as StarknetkitConnector[],
  });

  async function connectWallet() {
    const { connector } = await starknetkitConnectModal();
    if (!connector) {
      return;
    }
    await connect({ connector });
  }

  async function disconnectWallet() {
    await disconnect();
  }
  return (
    <div>
      <div>
        {address ? (
          <div>
            <p>Connected to: {address}</p>
            <button onClick={disconnectWallet}>Disconnect</button>
          </div>
        ) : (
          <button onClick={connectWallet}>Connect Wallet</button>
        )}
      </div>
    </div>
  );
};

export default ConnectButton;
