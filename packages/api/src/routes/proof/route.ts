import { ApproveProofDto, TransferProofDto } from "@/dtos/generate-proof.dto.js";
import { generateApproveProof, generateTransferProof } from "@/services/proof.service.js";
import { Request, Response, Router, NextFunction } from "express";

const router = Router();

router.post("/transfer", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body: TransferProofDto = req.body;
    const proofArray = await generateTransferProof(body);

    res.status(201).send(proofArray);
  } catch (error) {
    next(error);
  }
});

router.post("/approve", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body: ApproveProofDto = req.body;
    const proofArray = await generateApproveProof(body);

    res.status(201).send(proofArray);
  } catch (error) {
    next(error);
  }
});

export default router;
