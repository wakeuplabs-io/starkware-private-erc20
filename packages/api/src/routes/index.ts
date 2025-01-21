import { Router } from "express";

import testRoute from "./test/route.js";

const router = Router();

router.use("/test", testRoute);

export default router;
