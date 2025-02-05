import { Request, Response, Router, NextFunction } from "express";

const router = Router();

router.get("/", async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.status(200).json({ status: "UP" });
  } catch (error) {
    next(error);
  }
});

export default router;
