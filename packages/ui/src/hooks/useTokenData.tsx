import tokenAbi from "../abi/token.abi";
import {
  useReadContract,
  useNetwork,
  useAccount,
  useContract,
  useSendTransaction,
} from "@starknet-react/core";

export const useTokenData = () => {
  const { chain } = useNetwork();
  const { address } = useAccount();

  const ERC20_CONTRACT_ADDRESS =
    "0x049D36570D4e46f48e99674bd3fcc84644DdD6b96F7C741B1562B82f9e004dC7";

  // Leer balance
  const { data: balance, error: balanceError } = useReadContract({
    abi: tokenAbi,
    functionName: "balance_of",
    address: ERC20_CONTRACT_ADDRESS,
    args: [address],
  });

  // Instancia del contrato
  const { contract } = useContract({
    abi: tokenAbi,
    address: ERC20_CONTRACT_ADDRESS,
  });

  const { send, error: transferError, status } = useSendTransaction({ calls: undefined });

  const sendTransfer = async (recipientAddress: string, amount: bigint) => {
    if (!contract || !address) {
      throw new Error("Contract or account not initialized");
    }

    const callData = contract.populate("transfer", [recipientAddress, amount]);

    try {
      console.log({callData})
      await send([callData]);
    } catch (error) {
      console.error("Error sending transaction:", error);
      throw error;
    }
  };

  return {
    balance,
    sendTransfer,
    balanceError,
    transferError,
    tokenAddress: chain?.nativeCurrency?.address,
    status
  };
};
