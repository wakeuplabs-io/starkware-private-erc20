import { useContract, useSendTransaction } from "@starknet-react/core";
import { useState } from "react";
import privateTokenAbi from "@/abi/private-erc20.abi";
import { PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";

export const useApprove = () => {
  const [loading, setLoading] = useState(false);

  const { contract } = useContract({
    abi: privateTokenAbi,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const { sendAsync } = useSendTransaction({
    calls: undefined,
  });

  const sendApprove = async (props: { spender: bigint; amount: bigint }) => {
    try {
      if (!contract) {
        throw new Error("Contract not initialized");
      }

      setLoading(true);

      const callData = contract.populate("approve", [props.spender, props.amount]);

      await sendAsync([callData]);
    } finally {
      setLoading(false);
    }
  };

  return {
    sendApprove,
    loading,
  };
};
