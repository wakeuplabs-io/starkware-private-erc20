import { useContract, useProvider, useSendTransaction } from "@starknet-react/core";
import { useMemo, useState } from "react";
import privateTokenAbi from "@/abi/private-erc20.abi";
import { PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";
import { AccountService } from "@/services/account.service";
import { ProofService } from "@/services/proof.service";
import { Fr } from "@aztec/bb.js";
import { formatHex } from "@/lib/utils";
import { BarretenbergService } from "@/services/bb.service";
import { CipherService } from "@/services/cipher.service";
import { NotesService } from "@/services/notes.service";
import { Provider } from "starknet";

export const useApprove = () => {
  const { provider } = useProvider() as { provider: Provider };
  const [loading, setLoading] = useState(false);
  const { contract } = useContract({
    abi: privateTokenAbi,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const { sendAsync } = useSendTransaction({
    calls: undefined,
  });

  const notesService = useMemo(() => {
    return new NotesService(provider);
  }, [provider]);

  const sendApprove = async (props: {
    spender: {
      address: bigint;
      publicKey: bigint;
    }; amount: bigint
  }) => {
    try {

      
      if (!contract) {
        throw new Error("Contract not initialized");
      }

      setLoading(true);
      const approverAccount = await AccountService.getAccount();
      const notes = await notesService.getNotes();

      const senderNotes = notes.filter((n) => n.value !== undefined && n.spent !== true);
      const inputNote = senderNotes
        .sort((a, b) => parseInt((b.value! - a.value!).toString()))
        .find((n) => n.value! > props.amount);
      if (!inputNote) {
        throw new Error("Insufficient funds in notes");
      }

      const outAllowanceHash = await BarretenbergService.generateHashArray([
        new Fr(approverAccount.address),
        new Fr(props.spender.address),
        new Fr(props.amount),
      ]);

      const outRelationshipId = await BarretenbergService.generateHashArray([
        new Fr(approverAccount.address),
        new Fr(props.spender.address),
      ]);

      const generatedProof = await ProofService.generateApproveProof({
        in_private_key: formatHex(approverAccount.privateKey % Fr.MODULUS),
        in_amount: formatHex(props.amount),
        in_spender: formatHex(props.spender.address % Fr.MODULUS),
        out_allowance_hash: formatHex(outAllowanceHash),
        out_relationship_id: formatHex(outRelationshipId),
      });


      const decryptedOutput =  JSON.stringify({
        allowance: props.amount.toString(16),
        commitments: senderNotes.map(note => ({
          commitment: note.commitment.toString(16),
          value: inputNote.value!.toString(16),
          bliding: note.bliding!.toString(16),
        }))
      });

      const [encryptedSpenderOutput, encryptedApproverOutput] = await Promise.all([
        CipherService.encrypt(
          decryptedOutput,
          props.spender.publicKey
        ),
        CipherService.encrypt(
          decryptedOutput,
          approverAccount.publicKey
        ),
      ]);

      const callData = contract.populate("approve", [
        generatedProof,
        [encryptedSpenderOutput, encryptedApproverOutput],
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
