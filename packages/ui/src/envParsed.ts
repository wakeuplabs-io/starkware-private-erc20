import { z } from "zod";
import dotenv from "dotenv";

dotenv.config();

// NOTE: DO NOT destructure process.env

const env = {
  API_BASE_URL: import.meta.env.VITE_API_BASE_URL,
};

const envSchema = z
  .object({
    API_BASE_URL: z.string().default("http://localhost:5001"),
  })
  .required();

const envParsed = () => envSchema.parse(env);

export default envParsed;
