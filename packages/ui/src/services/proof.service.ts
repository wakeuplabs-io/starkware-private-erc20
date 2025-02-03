import { GenerateProofDto } from "@/interfaces";
import axios from "axios";

const API_URL = "http://localhost:5001/api/proof/generate"; // Ajustar según la URL real de tu backend

export const ProofService = {
  async generateProof(proofInputs: GenerateProofDto) {
    try {
      const response = await axios.post(API_URL, proofInputs, {
        headers: {
          "Content-Type": "application/json",
        },
      });
      return response.data; // Suponiendo que el backend responde con la prueba generada
    } catch (error) {
      console.error("Error generating proof:", error);
      throw error;
    }
  },
};
