import cors from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";

import envParsed from "@/envParsed.js";
import middlewares from "@/middlewares/index.js";
import routes from "@/routes/index.js";

const app = express();

app.use(morgan("dev"));
app.use(helmet());
app.use(cors({
  origin: "*",
}));
app.use(express.json());

app.use("/api", routes);

app.use(middlewares.notFound);
app.use(middlewares.errorHandler);

const port = parseInt(envParsed().PORT, 10);

app.listen(port, () => {
  console.log(`App Started at PORT=${port}`);
});
