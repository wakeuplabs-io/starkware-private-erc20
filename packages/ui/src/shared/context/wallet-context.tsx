import { createContext, useContext, useState } from "react";
import { AccountInterface, Provider } from "starknet";
import { connect, disconnect, StarknetWindowObject } from "starknetkit";
import { InjectedConnector } from "starknetkit/injected";
import { WebWalletConnector } from "starknetkit/webwallet";

type WalletState = {
  account: AccountInterface | null;
  isConnected: boolean;
  wallet: StarknetWindowObject | null;
  connectWallet: () => Promise<void>;
  disconnectWallet: () => Promise<void>;
};

const WalletContext = createContext<WalletState>({
  account: null,
  isConnected: false,
  wallet: null,
  connectWallet: () => Promise.resolve(),
  disconnectWallet: () => Promise.resolve(),
});

export const WalletProvider = ({ children }: { children: React.ReactNode }) => {
  const [isConnected, setIsConnected] = useState(false);
  const [wallet, setWallet] = useState<StarknetWindowObject | null>(null);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [account, setAccount] = useState<any | null>(null);

  const connectWallet = async () => {
    try {
      const { wallet, connector } = await connect({
        connectors: [
          new WebWalletConnector(),
          new InjectedConnector({ options: { id: "argentX" } }),
        ],
      });

      if (!wallet) {
        throw new Error("Wallet connection failed");
      }

      const provider = new Provider();
      const accountConnector = await connector?.account(provider);

      setAccount(accountConnector);
      setIsConnected(true);
      setWallet(wallet);
    } catch (error) {
      console.error("Failed to connect wallet:", error);
    }
  };

  const disconnectWallet = async () => {
    if (isConnected) {
      await disconnect();
      setIsConnected(false);
      setWallet(null);
      setAccount(null);
    }
  };
  return (
    <WalletContext.Provider
      value={{
        account,
        wallet,
        isConnected,
        connectWallet,
        disconnectWallet,
      }}
    >
      {children}
    </WalletContext.Provider>
  );
};

// eslint-disable-next-line react-refresh/only-export-components
export const useWallet = () => useContext(WalletContext);
