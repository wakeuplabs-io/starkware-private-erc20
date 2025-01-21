import envParsed from "./envParsed";

const TESTNET_PRIVATE_KEY = envParsed().TESTNET_PRIVATE_KEY;
const MAINNET_PRIVATE_KEY = envParsed().MAINNET_PRIVATE_KEY;
const API_KEY = envParsed().ETHERSCAN_API_KEY;

const sepolia = {
  url: "https://sepolia.drpc.org",
  chainId: 11155111,
  urls: {
    apiURL: "https://api-sepolia.etherscan.io/api",
    browserURL: "https://sepolia.etherscan.io",
  },
};

const optimism_sepolia = {
  url: "https://sepolia.optimism.io",
  chainId: 11155420,
  urls: {
    apiURL: "https://api-sepolia-optimism.etherscan.io/api",
    browserURL: "https://sepolia-optimism.etherscan.io",
  },
};

const base_sepolia = {
  url: "https://base-sepolia.public.blastapi.io",
  chainId: 84531,
  urls: {
    apiURL: "https://base-sepolia.explorer.gobob.xyz/api",
    browserURL: "https://base-sepolia.explorer.gobob.xyz/",
  },
};

const optimism = {
  url: "https://optimism.io",
  chainId: 10,
  urls: {
    apiURL: "https://api-optimism.etherscan.io/api",
    browserURL: "https://optimism.etherscan.io",
  },
};

const networks = {
  sepolia,
  ["optimism-sepolia"]: optimism_sepolia,
  ["base-sepolia"]: base_sepolia,
  optimism,
} as const;

export type Networks = keyof typeof networks;

export const getNetwork = (key: Networks, isTestnet: boolean) => {
  if (!key) {
    return undefined;
  }
  const network = networks[key];
  console.log("network", network);
  console.log("key", key);
  const networkKey = isTestnet ? "testnet" : "mainnet";
  const privateKey = isTestnet ? TESTNET_PRIVATE_KEY : MAINNET_PRIVATE_KEY;

  const customChain = {
    chainId: network.chainId,
    network: networkKey,
    urls: network.urls,
  };
  return {
    network: {
      url: network.url,
      accounts: [privateKey],
    },
    apiKeys: {
      [networkKey]: API_KEY,
    },
    customChains: [customChain],
  };
};
