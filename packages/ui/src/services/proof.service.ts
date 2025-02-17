import envParsed from "@/envParsed";
import {
  ApproveProofDto,
  DepositProofDto,
  TransferFromProofDto,
  TransferProofDto,
} from "@/interfaces";
import axios from "axios";
import { Fr } from "@aztec/bb.js";
import { formatHex } from "@/lib/utils";
import { DefinitionsService } from "./definitions.service";

export const ProofService = {
  async generateTransferProof(proofInputs: TransferProofDto) {
    try {
      const response = await axios.post(
        `${envParsed().API_BASE_URL}/api/proof/transfer`,
        proofInputs,
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );
      return response.data;
    } catch (error) {
      console.error("Error generating proof:", error);
      throw error;
    }
  },

  async generateApproveProof(props: {
    owner: {
      address: bigint;
      privateKey: bigint;
    };
    spender: {
      address: bigint;
    };
    amount: bigint;
  }) {
    try {
      const outAllowanceHash = await DefinitionsService.allowanceHash(
        props.owner.address,
        props.spender.address,
        props.amount
      );

      const outRelationshipId = await DefinitionsService.allowanceRelationship(
        props.owner.address,
        props.spender.address
      );

      const response = await axios.post(
        `${envParsed().API_BASE_URL}/api/proof/approve`,
        {
          in_private_key: formatHex(props.owner.privateKey % Fr.MODULUS),
          in_amount: formatHex(props.amount),
          in_spender: formatHex(props.spender.address % Fr.MODULUS),
          out_allowance_hash: formatHex(outAllowanceHash),
          out_relationship_id: formatHex(outRelationshipId),
        } as ApproveProofDto,
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );
      return response.data;
    } catch (error) {
      console.error("Error generating proof:", error);
      throw error;
    }
  },

  async generateTransferFromProof(proofInputs: TransferFromProofDto) {
    try {
      const response = await axios.post(
        `${envParsed().API_BASE_URL}/api/proof/transfer-from`,
        proofInputs,
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );
      return response.data;
    } catch (error) {
      console.error("Error generating proof:", error);
      throw error;
    }
  },

  async generateDepositProof(proofInputs: DepositProofDto) {
    try {
      const response = await axios.post(`${envParsed().API_BASE_URL}/api/proof/deposit`, proofInputs, {
        headers: {
          "Content-Type": "application/json",
        },
      });
      return response.data;
    } catch (error) {
      console.error("Error generating proof:", error);
      throw error;
    }
  },
};
