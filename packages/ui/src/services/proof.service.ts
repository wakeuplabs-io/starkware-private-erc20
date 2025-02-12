import envParsed from "@/envParsed";
import { ApproveProofDto, TransferProofDto } from "@/interfaces";
import axios from "axios";

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

  async generateApproveProof(proofInputs: ApproveProofDto) {
    try {
      const response = await axios.post(`${envParsed().API_BASE_URL}/api/proof/approve`, proofInputs, {
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
