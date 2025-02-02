import cors from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";

import serverless from "serverless-http";

import envParsed from "@/envParsed.js";
import middlewares from "@/middlewares/index.js";
import routes from "@/routes/index.js";

const app = express();

app.use(morgan("dev"));
app.use(helmet());
app.use(cors());
app.use(express.json());

app.use("/api", routes);

app.use(middlewares.notFound);
app.use(middlewares.errorHandler);

const port = parseInt(envParsed().PORT, 10);

app.listen(port, "0.0.0.0", () => {
  console.log(`App Started at PORT=${port}`);
});


export const handler = serverless(app);
