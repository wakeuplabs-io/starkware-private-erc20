import { useContract, useSendTransaction } from "@starknet-react/core";
import { useState } from "react";
import { PRIVATE_ERC20_ABI, PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/shared/config/constants";
import { AccountService } from "@/services/account.service";
import { ProofService } from "@/services/proof.service";
import { Fr } from "@aztec/bb.js";
import { formatHex } from "@/lib/utils";
import { BarretenbergService } from "@/services/bb.service";
import { CipherService } from "@/services/cipher.service";

export const useApprove = () => {
  const [loading, setLoading] = useState(false);

  const { contract } = useContract({
    abi: PRIVATE_ERC20_ABI,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const { sendAsync } = useSendTransaction({
    calls: undefined,
  });

  const sendApprove = async (props: { spender: bigint; amount: bigint }) => {
    setLoading(true);
    
    try {
      if (!contract) {
        throw new Error("Contract not initialized");
      }

      const approverAccount = await AccountService.getAccount();

      const outAllowanceHash = await BarretenbergService.generateHashArray([
        new Fr(approverAccount.address),
        new Fr(props.spender),
        new Fr(props.amount),
      ]);

      const outRelationshipId = await BarretenbergService.generateHashArray([
        new Fr(approverAccount.address),
        new Fr(props.spender),
      ]);

      const generatedProof = await ProofService.generateApproveProof({
        in_private_key: formatHex(approverAccount.privateKey % Fr.MODULUS),
        in_amount: formatHex(props.amount),
        in_spender: formatHex(props.spender % Fr.MODULUS),
        out_allowance_hash: formatHex(outAllowanceHash),
        out_relationship_id: formatHex(outRelationshipId),
      });

      const encryptedOutput = CipherService.encrypt(
        JSON.stringify([
          {
            // TODO:
            // commitment: inputNote.commitment,
            // value: inputNote.value,
            // bliding: inputNote.bliding,
          },
        ]),
        props.spender
      );

      const callData = contract.populate("approve", [
        generatedProof,
        encryptedOutput,
      ]);

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
