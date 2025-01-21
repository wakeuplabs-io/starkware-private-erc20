import { Request, Response, Router, NextFunction } from "express";

const router = Router();

router.get("/", async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.status(200).send("Hello World from github!");
  } catch (error) {
    next(error);
  }
});

export default router;
