import { CIRCUIT_TYPE } from "@/constants.js";
import { GenerateProofDto } from "@/dtos/generate-proof.dto.js";
import { generateProof } from "@/services/proof.service.js";
import { Request, Response, Router, NextFunction } from "express";

const router = Router();

router.post("/transfer", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body: GenerateProofDto = req.body;
    const proofArray = await generateProof(CIRCUIT_TYPE.TRANSFER, body);

    res.status(201).send(proofArray);
  } catch (error) {
    next(error);
  }
});

router.post("/approve", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body: GenerateProofDto = req.body;
    const proofArray = await generateProof(CIRCUIT_TYPE.APPROVE, body);

    res.status(201).send(proofArray);
  } catch (error) {
    next(error);
  }
});

export default router;
