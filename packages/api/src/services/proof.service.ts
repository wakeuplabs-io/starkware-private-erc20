import fs from "fs/promises";
import { exec } from "child_process";
import { promisify } from "util";
import path from "path";
import { GenerateProofDto } from "@/dtos/generate-proof.dto.js";
import { fileURLToPath } from "url";

const execPromise = promisify(exec);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROVER_TOML_PATH = path.join(__dirname, "../../circuit/transfer/Prover.toml");
const CIRCUIT_PATH = path.join(__dirname, "../../circuit/transfer");

export async function generateProofFile(input: GenerateProofDto): Promise<void> {
  const tomlContent = `
amount = "${input.amount}"
balance = "${input.balance}"
receiver_address = "${input.receiver_address}"
commitment = "${input.commitment}"
direction_selector = ${JSON.stringify(input.direction_selector)}
nullifier = "${input.nullifier}"
nullifier_hash = "${input.nullifier_hash}"
path = ${JSON.stringify(input.path)}
root = "${input.root}"
`;

  await fs.writeFile(PROVER_TOML_PATH, tomlContent, "utf-8");
}

export async function generateProof(): Promise<string[]> {
  try {
    await execPromise("nargo execute", { cwd: CIRCUIT_PATH });
    console.log("nargo executed");
    await execPromise("/root/.bb/bb prove_ultra_keccak_honk -b target/transfer.json -w target/transfer.gz -o target/transfer_proof.bin", { cwd: CIRCUIT_PATH });
    console.log("proof generated");
    await execPromise("/root/.bb/bb write_vk_ultra_keccak_honk -b target/transfer.json -o ./target/vk.bin", { cwd: CIRCUIT_PATH });
    console.log("vk generated");
    const { stdout } = await execPromise("garaga calldata --system ultra_keccak_honk --vk target/vk.bin --proof target/transfer_proof.bin --format array", { cwd: CIRCUIT_PATH });
    const trimmedStdout = stdout.trim();
    const modifiedStdout = trimmedStdout.substring(1, trimmedStdout.length - 1);
    return modifiedStdout.split(",").map((x) => x.trim());
  } catch (error) {
    throw new Error(`Error generating proof: ${(error as Error).message}`);
  }
}
