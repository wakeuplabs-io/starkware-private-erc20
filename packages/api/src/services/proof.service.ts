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
const PROOFS_MAX_LENGTH = 20;

export async function generateProofFile(input: GenerateProofDto): Promise<void> {
  const tomlContent = `
    amount = "${input.amount}"
    balance = "${input.balance}"
    receiver_account = "${input.receiver_account}"
    change_account = "${input.change_account}"
    secret_sender_account = "${input.secret_sender_account}"
    nullifier = "${input.nullifier}"
    nullifier_hash = "${input.nullifier_hash}"
    root = "${input.root}"

    path = ${JSON.stringify(input.path)}
    direction_selector = ${JSON.stringify(input.direction_selector)}

    out_commitment = ${JSON.stringify(input.out_commitment)}

    new_root = "${input.new_root}"
    new_path = ${JSON.stringify(input.new_path)}
    new_direction_selector = ${JSON.stringify(input.new_direction_selector)}

    new_path_change = ${JSON.stringify(input.new_path_change)}
    new_direction_selector_change = ${JSON.stringify(input.new_direction_selector_change)}
    `.trim();

  await fs.writeFile(PROVER_TOML_PATH, tomlContent, "utf-8");
}

export async function generateProof(): Promise<string[]> {
  try {
    const vkPath = path.join(CIRCUIT_PATH, "target/vk.bin");
    const proofDir = path.join(CIRCUIT_PATH, "target/proofs");

    const vkExists = await fs
      .access(vkPath)
      .then(() => true)
      .catch(() => false);

    if (!vkExists) {
      await execPromise("nargo execute", { cwd: CIRCUIT_PATH });
      console.log("nargo executed");
      await execPromise("/root/.bb/bb write_vk_ultra_keccak_honk -b target/transfer.json -o ./target/vk.bin", {
        cwd: CIRCUIT_PATH,
      });
      console.log("vk generated");
    } else{
      console.log("vk was generated");
    }


    await fs.mkdir(proofDir, { recursive: true });

    const timestamp = Date.now();
    const proofPath = path.join(proofDir, `transfer_proof_${timestamp}.bin`);

    await execPromise(`/root/.bb/bb prove_ultra_keccak_honk -b target/transfer.json -w target/transfer.gz -o ${proofPath}`, {
      cwd: CIRCUIT_PATH,
    });
    console.log(`Proof generated: ${proofPath}`);

    const { stdout } = await execPromise(
      `garaga calldata --system ultra_keccak_honk --vk target/vk.bin --proof ${proofPath} --format array`,
      { cwd: CIRCUIT_PATH }
    );
    const trimmedStdout = stdout.trim();
    const modifiedStdout = trimmedStdout.substring(1, trimmedStdout.length - 1);
    
    const proofFiles = (await fs.readdir(proofDir))
      .filter(file => file.startsWith("transfer_proof_") && file.endsWith(".bin"))
      .sort((a, b) => parseInt(a.split("_")[2]) - parseInt(b.split("_")[2]));

    if (proofFiles.length > PROOFS_MAX_LENGTH) {
      const filesToDelete = proofFiles.slice(0, proofFiles.length - 10);
      for (const file of filesToDelete) {
        await fs.unlink(path.join(proofDir, file));
      }
      console.log(`Cleanup done: Removed ${filesToDelete.length} old proof files.`);
    }

    return modifiedStdout.split(",").map((x) => x.trim());
  } catch (error) {
    throw new Error(`Error generating proof: ${(error as Error).message}`);
  }
}
