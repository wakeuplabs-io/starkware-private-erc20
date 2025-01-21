import { Address, GetContractReturnType, erc20Abi, getContract } from "viem";
import { Clients } from "../types";


export const createERC20Contract = (
  clients: Clients,
  address: Address
): GetContractReturnType<typeof erc20Abi, Clients, Address> => {
  return getContract({
    address: address,
    abi: erc20Abi,
    client: {
      public: clients.public,
      wallet: clients.wallet,
    },
  }) as GetContractReturnType<typeof erc20Abi, Clients, Address>;
};

