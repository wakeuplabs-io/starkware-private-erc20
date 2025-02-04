import React from "react";
 
import { InjectedConnector } from "starknetkit/injected";
import { WebWalletConnector } from "starknetkit/webwallet";
import { sepolia } from "@starknet-react/chains";
import { StarknetConfig, publicProvider } from "@starknet-react/core";
 
export default function StarknetProvider({ children }: { children: React.ReactNode }) {
  const chains = [sepolia];
 
  const connectors = [
    new InjectedConnector({ options: { id: "braavos", name: "Braavos" }}),
    new InjectedConnector({ options: { id: "argentX", name: "Argent X" }}),
    new WebWalletConnector({ url: "https://web.argent.xyz" }),
  ];
 
  return(
    <StarknetConfig
      chains={chains}
      provider={publicProvider()}
      connectors={connectors}
    >
      {children}
    </StarknetConfig>
  );
}