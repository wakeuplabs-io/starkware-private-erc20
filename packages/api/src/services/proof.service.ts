import fs from "fs/promises";
import { exec } from "child_process";
import { promisify } from "util";
import path from "path";
import { ApproveProofDto, TransferFromProofDto, TransferProofDto } from "@/dtos/generate-proof.dto.js";
import { fileURLToPath } from "url";
import { randomUUID } from "crypto";
import os from "os";
import { stringify as tomlStringify } from "smol-toml";

const execPromise = promisify(exec);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const CIRCUITS_PATH = path.join(__dirname, "../../circuits");
const TRANSFER_CIRCUIT_PATH = path.join(__dirname, "../../circuits/transfer");
const TRANSFER_FROM_CIRCUIT_PATH = path.join(__dirname, "../../circuits/transfer_from");
const APPROVE_CIRCUIT_PATH = path.join(__dirname, "../../circuits/approve");

export async function generateTransferProof(
  input: TransferProofDto
): Promise<string[]> {
  const ACIR_PATH = path.join(CIRCUITS_PATH, "transfer/target/transfer.json");
  const VK_PATH = path.join(CIRCUITS_PATH, "transfer/target/vk.bin");
  const TMP_DIR = os.tmpdir();

  const proofId = randomUUID().toString();
  const proverPath = path.join(TMP_DIR, `${proofId}-prover.toml`);
  const witnessName = path.join(TMP_DIR, `${proofId}-witness.gz`);
  const proofPath = path.join(TMP_DIR, `${proofId}-proof.bin`);
  try {
    // generate prover file
    await fs.writeFile(proverPath, tomlStringify(input), "utf-8");

    // generate witness
    await execPromise(`nargo execute -p ${proverPath} ${witnessName}`, {
      cwd: CIRCUITS_PATH,
    });

    // generate proof
    await execPromise(
      `bb prove_ultra_keccak_honk -b ${ACIR_PATH} -w ${witnessName} -o ${proofPath}`,
      {
        cwd: TRANSFER_CIRCUIT_PATH,
      }
    );

    // generate calldata
    const { stdout } = await execPromise(
      `garaga calldata --system ultra_keccak_honk --vk ${VK_PATH} --proof ${proofPath} --format array`,
      { cwd: TRANSFER_CIRCUIT_PATH }
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


export async function generateApproveProof(
  input: ApproveProofDto
): Promise<string[]> {
  const ACIR_PATH = path.join(APPROVE_CIRCUIT_PATH, "target/approve.json");
  const VK_PATH = path.join(APPROVE_CIRCUIT_PATH, "target/vk.bin");
  const TMP_DIR = os.tmpdir();

  const proofId = randomUUID().toString();
  const proverPath = path.join(TMP_DIR, `${proofId}-prover.toml`);
  const witnessName = path.join(TMP_DIR, `${proofId}-witness.gz`);
  const proofPath = path.join(TMP_DIR, `${proofId}-proof.bin`);
  try {
    // generate prover file
    await fs.writeFile(proverPath, tomlStringify(input), "utf-8");

    // generate witness
    await execPromise(`nargo execute -p ${proverPath} ${witnessName}`, {
      cwd: APPROVE_CIRCUIT_PATH,
    });

    // generate proof
    await execPromise(
      `bb prove_ultra_keccak_honk -b ${ACIR_PATH} -w ${witnessName} -o ${proofPath}`,
      {
        cwd: APPROVE_CIRCUIT_PATH,
      }
    );

    // generate calldata
    const { stdout } = await execPromise(
      `garaga calldata --system ultra_keccak_honk --vk ${VK_PATH} --proof ${proofPath} --format array`,
      { cwd: APPROVE_CIRCUIT_PATH }
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


export async function generateTransferFromProof(
  input: TransferFromProofDto
): Promise<string[]> {
  const ACIR_PATH = path.join(TRANSFER_FROM_CIRCUIT_PATH, "target/transfer_from.json");
  const VK_PATH = path.join(TRANSFER_FROM_CIRCUIT_PATH, "target/vk.bin");
  const TMP_DIR = os.tmpdir();

  const proofId = randomUUID().toString();
  const proverPath = path.join(TMP_DIR, `${proofId}-prover.toml`);
  const witnessName = path.join(TMP_DIR, `${proofId}-witness.gz`);
  const proofPath = path.join(TMP_DIR, `${proofId}-proof.bin`);
  try {
    // generate prover file
    await fs.writeFile(proverPath, tomlStringify(input), "utf-8");

    // generate witness
    await execPromise(`nargo execute -p ${proverPath} ${witnessName}`, {
      cwd: TRANSFER_FROM_CIRCUIT_PATH,
    });

    // generate proof
    await execPromise(
      `bb prove_ultra_keccak_honk -b ${ACIR_PATH} -w ${witnessName} -o ${proofPath}`,
      {
        cwd: TRANSFER_FROM_CIRCUIT_PATH,
      }
    );

    // generate calldata
    const { stdout } = await execPromise(
      `garaga calldata --system ultra_keccak_honk --vk ${VK_PATH} --proof ${proofPath} --format array`,
      { cwd: TRANSFER_FROM_CIRCUIT_PATH }
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

