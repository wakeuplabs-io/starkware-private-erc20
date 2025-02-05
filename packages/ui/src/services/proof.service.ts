import envParsed from "@/envParsed";
import { GenerateProofDto } from "@/interfaces";
import axios from "axios";

const API_URL = `${envParsed().API_BASE_URL}/api/proof/generate`;

export const ProofService = {
  async generateProof(proofInputs: GenerateProofDto) {
    try {
      const response = await axios.post(`${API_URL}/proof/generate`, proofInputs, {
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
