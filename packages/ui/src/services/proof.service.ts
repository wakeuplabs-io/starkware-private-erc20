import { API_URL } from "@/constants";
import { GenerateProofDto } from "@/interfaces";
import axios from "axios";


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
