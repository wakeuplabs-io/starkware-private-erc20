import { GenerateProofDto } from "@/dtos/generate-proof.dto.js";
import { generateProof } from "@/services/proof.service.js";
import { Request, Response, Router, NextFunction } from "express";

const router = Router();

router.post("/generate", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body: GenerateProofDto = req.body;
    const proofArray = await generateProof(body);

    res.status(201).send(proofArray);
  } catch (error) {
    next(error);
  }
});

export default router;
