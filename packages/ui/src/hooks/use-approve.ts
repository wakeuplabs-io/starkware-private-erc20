import {
  useContract,
  useProvider,
  useSendTransaction,
} from "@starknet-react/core";
import { useMemo, useState } from "react";
import {
  PRIVATE_ERC20_ABI,
  PRIVATE_ERC20_CONTRACT_ADDRESS,
} from "@/shared/config/constants";
import { AccountService } from "@/services/account.service";
import { ProofService } from "@/services/proof.service";
import { Fr } from "@aztec/bb.js";
import { formatHex, stringify } from "@/lib/utils";
import { BarretenbergService } from "@/services/bb.service";
import { CipherService } from "@/services/cipher.service";
import { NotesService } from "@/services/notes.service";
import { Provider } from "starknet";
import { ApprovalPayload } from "@/interfaces";
import { PhoneForwarded } from "lucide-react";

export const useApprove = () => {
  const { provider } = useProvider() as { provider: Provider };
  const [loading, setLoading] = useState(false);
  const { contract } = useContract({
    abi: PRIVATE_ERC20_ABI,
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
    };
    amount: bigint;
  }): Promise<string> => {
    setLoading(true);

    try {
      if (!contract) {
        throw new Error("Contract not initialized");
      }

      const approverAccount = await AccountService.getAccount();

      const { notesArray: notes } = await notesService.getNotes();
      const senderNotes = notes.filter(
        (n) => n.value !== undefined && n.spent !== true
      );

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

      // generate encrypted data
      const approvalPayload: ApprovalPayload = {
        allowance: props.amount,
        commitments: senderNotes.map((note) => ({
          commitment: note.commitment,
          value: note.value!,
          bliding: note.bliding!,
        })),
      };

      const [encryptedSpenderOutput, encryptedApproverOutput] =
        await Promise.all([
          CipherService.encrypt(
            stringify(approvalPayload),
            props.spender.publicKey
          ),
          CipherService.encrypt(
            stringify(approvalPayload),
            approverAccount.publicKey
          ),
        ]);

      const { transaction_hash } = await sendAsync([
        contract.populate("approve", [
          generatedProof,
          encryptedApproverOutput,
          encryptedSpenderOutput,
        ]),
      ]);
      return transaction_hash;
    } finally {
      setLoading(false);
    }
  };

  return {
    sendApprove,
    loading,
  };
};
