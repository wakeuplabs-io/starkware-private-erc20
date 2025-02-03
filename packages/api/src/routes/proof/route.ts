import { GenerateProofDto } from "@/dtos/generate-proof.dto.js";
import { generateProof, generateProofFile } from "@/services/proof.service.js";
import { Request, Response, Router, NextFunction } from "express";

const router = Router();


router.post("/generate", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body: GenerateProofDto = req.body;
    await generateProofFile(body);

    // Ejecutar generación de prueba y calldata
    const proofArray = await generateProof();
    res.status(201).send(proofArray);
  } catch (error) {
    next(error);
  }
});

export default router;
