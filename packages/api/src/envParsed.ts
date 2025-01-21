import { z } from "zod";
import dotenv from "dotenv";

dotenv.config();

// NOTE: DO NOT destructure process.env

const env = {
  NODE_ENV: process.env.NODE_ENV,
  PORT: process.env.PORT,
};

const envSchema = z
  .object({
    NODE_ENV: z.enum(["development", "production"]).default("development"),
    PORT: z.string().default("5000"),
  })
  .required();

const envParsed = () => envSchema.parse(env);

export default envParsed;
