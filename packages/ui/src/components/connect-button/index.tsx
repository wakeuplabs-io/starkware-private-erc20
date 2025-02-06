import { StarknetkitConnector, useStarknetkitConnectModal } from "starknetkit";
import { useAccount, useConnect, useDisconnect } from "@starknet-react/core";
import { add } from "libsodium-wrappers";
import { Button } from "../ui/button";
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

  const shortenAddress = (addr: string) => {
    return addr.slice(0, 6) + "..." + addr.slice(addr.length - 4);
  };

  return (
    <div>
      {address ? (
        <Button onClick={disconnectWallet}>
          Disconnect ({shortenAddress(address)})
        </Button>
      ) : (
        <Button onClick={connectWallet}>Connect Wallet</Button>
      )}
    </div>
  );
};
export default ConnectButton;
