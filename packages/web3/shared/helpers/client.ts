import hre from "hardhat";

/**
 * Retrieves wallet clients and a public client for interacting with the blockchain.
 * @returns An object containing the public client and wallet clients: owner, investorOne, and investorTwo.
 */
export const getClient = async () => {
  const [owner, investorOne, investorTwo] = await hre.viem.getWalletClients();
  const publicClient = await hre.viem.getPublicClient();

  return {
    publicClient,
    owner,
    investorOne,
    investorTwo,
  } as const;
};

export type Clients = Awaited<ReturnType<typeof getClient>>;
