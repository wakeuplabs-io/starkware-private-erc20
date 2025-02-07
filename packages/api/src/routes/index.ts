import { Router } from "express";

import proofRouter from "./proof/route.js";
import healthRouter from "./health/route.js";

const router = Router();

router.use("/health", healthRouter);
router.use("/proof", proofRouter);

export default router;
