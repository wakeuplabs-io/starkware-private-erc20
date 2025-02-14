import { useContract, useSendTransaction } from "@starknet-react/core";
import { useCallback, useState } from "react";
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
import { ApprovalPayload } from "@/interfaces";
import { notesService } from "@/services/notes.service";

export const useApprove = () => {
  const [loading, setLoading] = useState(false);
  const { contract } = useContract({
    abi: PRIVATE_ERC20_ABI,
    address: PRIVATE_ERC20_CONTRACT_ADDRESS,
  });

  const { sendAsync } = useSendTransaction({
    calls: undefined,
  });

  const sendApprove = useCallback(
    async (props: {
      spender: {
        address: bigint;
        publicKey: bigint;
      };
      amount: bigint;
      shareViewingKey: boolean;
    }): Promise<string> => {
      try {
        if (!contract) {
          throw new Error("Contract not initialized");
        }
        setLoading(true);

        const ownerAccount = await AccountService.getAccount();

        // generate approve proof

        const generatedProof = await ProofService.generateApproveProof({
          owner: {
            address: ownerAccount.owner.address,
            privateKey: ownerAccount.owner.privateKey,
          },
          spender: { address: props.spender.address },
          amount: props.amount,
        });

        // generate approval payload

        const { notesArray: notes } = await notesService.getNotes();

        let approvedCommitments: ApprovalPayload["commitments"] = [];
        if (!props.shareViewingKey) {
          approvedCommitments = notes.reduce(
            (acc, note) => {
              if (note.value !== undefined && note.spent !== true) {
                acc.push({
                  commitment: note.commitment,
                  value: note.value!,
                  bliding: note.bliding!,
                });
              }
              return acc;
            },
            [] as ApprovalPayload["commitments"]
          );

          if (approvedCommitments.length === 0) {
            throw new Error(
              "No balance to approve. Try sharing viewing key for extended approvals."
            );
          }
        }

        const approvalPayload: ApprovalPayload = {
          allowance: props.amount,
          view: {
            privateKey: props.shareViewingKey ? ownerAccount.viewer.privateKey : 0n,
            publicKey: props.shareViewingKey ? ownerAccount.viewer.publicKey : 0n,
          },
          commitments: approvedCommitments,
        };

        const [encryptedSpenderOutput, encryptedApproverOutput] =
          await Promise.all([
            CipherService.encrypt(
              stringify(approvalPayload),
              props.spender.publicKey
            ),
            CipherService.encrypt(
              stringify(approvalPayload),
              ownerAccount.viewer.publicKey
            ),
          ]);

        // contract call

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
    },
    [contract, sendAsync]
  );

  return {
    sendApprove,
    loading,
  };
};
