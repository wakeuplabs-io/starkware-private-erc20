import { Request, Response, Router, NextFunction } from "express";

import proofRoute from "./proof/route.js";

const router = Router();

router.get("/health", async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.status(200).json({ status: "UP" });
  } catch (error) {
    next(error);
  }
});

router.use("/proof", proofRoute);

export default router;
