import { PublicClient, WalletClient } from "viem";

export type Clients = {
  public: PublicClient;
  wallet: WalletClient;
};
