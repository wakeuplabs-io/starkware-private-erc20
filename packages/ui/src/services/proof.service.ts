import envParsed from "@/envParsed";
import { ApproveProofDto, TransferFromProofDto, TransferProofDto } from "@/interfaces";
import axios from "axios";
import { BarretenbergService } from "./bb.service";
import { Fr } from "@aztec/bb.js";
import { formatHex } from "@/lib/utils";
import { hash } from "starknet";

export const ProofService = {
  async generateTransferProof(proofInputs: TransferProofDto) {
    try {
      const response = await axios.post(`${envParsed().API_BASE_URL}/api/proof/transfer`, proofInputs, {
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

  async generateApproveProof(props: {
    owner: {
      address: bigint;
      privateKey: bigint;
    },
    spender: {
      address: bigint;
    },
    amount: bigint,
  }) {
    try {
      const outAllowanceHash = await BarretenbergService.generateHashArray([
        new Fr(props.owner.address),
        new Fr(props.spender.address),
        new Fr(props.amount),
      ]);

      const outRelationshipId = await BarretenbergService.generateHashArray([
        new Fr(props.owner.address % Fr.MODULUS),
        new Fr(props.spender.address % Fr.MODULUS),
      ]);
      console.log("relationshipId", outRelationshipId.toString(16), hash.computePoseidonHashOnElements([outRelationshipId]));
      // 1667f025ed7a1481b466fa6688e6113dc27ff8a9c24dc64cdf4f72c380bfd52d 0x5871fb0f7ac003a7ef74b7d4da02ce788e5b3063d63c5fe0f35747c98280c8d

      const response = await axios.post(`${envParsed().API_BASE_URL}/api/proof/approve`, {
        in_private_key: formatHex(props.owner.privateKey % Fr.MODULUS),
        in_amount: formatHex(props.amount),
        in_spender: formatHex(props.spender.address % Fr.MODULUS),
        out_allowance_hash: formatHex(outAllowanceHash),
        out_relationship_id: formatHex(outRelationshipId),
      } as ApproveProofDto, {
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

  async generateTransferFromProof(proofInputs: TransferFromProofDto) {
    try {
      const response = await axios.post(`${envParsed().API_BASE_URL}/api/proof/transfer-from`, proofInputs, {
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
