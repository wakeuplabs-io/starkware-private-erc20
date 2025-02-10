import fs from "fs/promises";
import { exec } from "child_process";
import { promisify } from "util";
import path from "path";
import { GenerateProofDto } from "@/dtos/generate-proof.dto.js";
import { fileURLToPath } from "url";
import { randomUUID } from "crypto";
import os from "os";
import { stringify as tomlStringify } from "smol-toml";
import { CIRCUIT_TYPE } from "@/constants.js";

const execPromise = promisify(exec);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const TRANSFER_CIRCUIT_PATH = path.join(__dirname, "../../circuits/transfer");
const APPROVE_CIRCUIT_PATH = path.join(__dirname, "../../circuits/approve");
const ACIR_PATH = path.join(TRANSFER_CIRCUIT_PATH, "target/transfer.json");
const VK_PATH = path.join(TRANSFER_CIRCUIT_PATH, "target/vk.bin");
const TMP_DIR = os.tmpdir();

export async function generateProof(
  circuitName: CIRCUIT_TYPE,
  input: GenerateProofDto
): Promise<string[]> {
  const proofId = randomUUID().toString();
  const proverPath = path.join(TMP_DIR, `${proofId}-prover.toml`);
  const witnessName = path.join(TMP_DIR, `${proofId}-witness.gz`);
  const proofPath = path.join(TMP_DIR, `${proofId}-proof.bin`);
  let circuitPath = "transfer";

  if(circuitName === CIRCUIT_TYPE.APPROVE) {
    circuitPath = APPROVE_CIRCUIT_PATH;
  }

  try {
    // generate prover file
    await fs.writeFile(proverPath, tomlStringify(input), "utf-8");

    // generate witness
    await execPromise(`nargo execute -p ${proverPath} ${witnessName}`, {
      cwd: circuitPath,
    });

    // generate proof
    await execPromise(
      `bb prove_ultra_keccak_honk -b ${ACIR_PATH} -w ${witnessName} -o ${proofPath}`,
      {
        cwd: circuitPath,
      }
    );

    // generate calldata
    const { stdout } = await execPromise(
      `garaga calldata --system ultra_keccak_honk --vk ${VK_PATH} --proof ${proofPath} --format array`,
      { cwd: circuitPath }
    );

    const trimmedStdout = stdout.trim();
    const calldata = trimmedStdout.substring(1, trimmedStdout.length - 1);

    return calldata.split(",").map((x) => x.trim());
  } catch (error) {
    console.error("Error occurred during proof generation:", error);
    throw new Error(`Proof generation failed: ${(error as Error).message}`);
  } finally {
    await Promise.allSettled([
      fs.unlink(proverPath),
      fs.unlink(witnessName),
      fs.unlink(proofPath),
    ]).catch(() => console.log("cleanup failed"));
  }
}
