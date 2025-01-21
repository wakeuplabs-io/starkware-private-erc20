import envParsed from "@/envParsed.js";
import { Request, Response, NextFunction } from "express";

export const STATUS_CODES = {
  NOT_FOUND: 404,
  INTERNAL_SERVER_ERROR: 500,
  OK: 200,
};

function notFound(req: Request, res: Response, next: NextFunction) {
  res.status(STATUS_CODES.NOT_FOUND);

  const error = new Error(`🔍 - Not Found - ${req.originalUrl}`);

  next(error);
}

/* eslint-disable no-unused-vars */
function errorHandler(err: unknown, req: Request, res: Response) {
  console.error(err);

  const statusCode = res.statusCode !== 200 ? res.statusCode : STATUS_CODES.INTERNAL_SERVER_ERROR;

  const message = err && (err instanceof Error || (typeof err === "object" && "message" in err)) ? err.message : "Internal Server Error";

  const stack = envParsed().NODE_ENV === "development" && err && typeof err === "object" && "stack" in err ? err.stack : undefined;

  res.status(statusCode);
  res.json({
    message,
    stack,
  });
}

export default { notFound, errorHandler };
