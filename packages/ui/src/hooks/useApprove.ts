import { useContract, useSendTransaction } from "@starknet-react/core";
import { useState } from "react";
import privateTokenAbi from "@/abi/private-erc20.abi";
import { PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";
import { AccountService } from "@/services/account.service";
import { ProofService } from "@/services/proof.service";
import { Fr } from "@aztec/bb.js";
import { formatHex } from "@/utils/hex";
import { useNotes } from "./useNotes";
import { BarretenbergService } from "@/services/bb.service";
import { CipherService } from "@/services/cipher.service";

export const useApprove = () => {
  const { notes } = useNotes();
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
      const approverAccount = await AccountService.getAccount();
      const senderNotes = notes.filter((n) => n.value !== undefined);

      const inputNote = senderNotes
        .sort((a, b) => parseInt((b.value! - a.value!).toString()))
        .find((n) => n.value! > props.amount);

      if (!inputNote) {
        throw new Error("Insufficient funds in notes");
      }

      const outAllowanceHash = await BarretenbergService.generateHashArray([
        new Fr(approverAccount.address),
        new Fr(props.spender),
        new Fr(props.amount),
      ]);

      const outRelationshipId = await BarretenbergService.generateHashArray([
        new Fr(approverAccount.address),
        new Fr(props.spender),
      ]);

      const generatedProof = await ProofService.generateProof({
        in_private_key: formatHex(approverAccount.privateKey % Fr.MODULUS),
        in_amount: formatHex(inputNote.value!),
        in_spender: formatHex(props.spender % Fr.MODULUS),
        out_allowance_hash: formatHex(outAllowanceHash),
        out_relationship_id: formatHex(outRelationshipId),
      });

      const encryptedOutput = CipherService.encrypt(
        JSON.stringify([
          {
            commitment: inputNote.commitment,
            value: inputNote.value,
            bliding: inputNote.bliding,
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
