import { Fr } from "@aztec/bb.js";
import { CipherService } from "./cipher.service";
import { BarretenbergService } from "./bb.service";
import { stringify } from "@/lib/utils";

export class DefinitionsService {
  static async generateNote(
    toAddress: bigint,
    toPublicKey: bigint,
    value: bigint
  ): Promise<{
    commitment: bigint;
    encOutput: string;
    bliding: bigint;
    value: bigint;
  }> {
    const randomBytes = crypto.getRandomValues(new Uint8Array(16)); // 16 bytes for up to 128-bit range
    const bliding = BigInt(
      "0x" +
        [...randomBytes].map((b) => b.toString(16).padStart(2, "0")).join("")
    );

    const commitment = await BarretenbergService.generateHashArray([
      new Fr(toAddress),
      new Fr(value),
      new Fr(bliding),
    ]);

    const encOutput = await CipherService.encrypt(
      stringify({
        bliding: bliding,
        value: value,
      }),
      toPublicKey
    );

    return {
      commitment,
      encOutput,
      bliding,
      value,
    };
  }

  static async generateCommitmentTracker(
    commitment: bigint,
    bliding: bigint
  ): Promise<bigint> {
    const tracker = await BarretenbergService.generateHashArray([
      new Fr(commitment % Fr.MODULUS),
      new Fr(bliding % Fr.MODULUS),
    ]);
    return tracker;
  }

  static async generateNullifier(
    commitment: bigint,
    privateKey: bigint,
    index: bigint
  ): Promise<bigint> {
    const nullifier = await BarretenbergService.generateHashArray([
      new Fr(commitment % Fr.MODULUS),
      new Fr(privateKey % Fr.MODULUS),
      new Fr(index % Fr.MODULUS),
    ]);
    return nullifier;
  }

  static async generateSpendingTracker(
    commitment: bigint,
    bliding: bigint
  ): Promise<bigint> {
    const nullifier = await BarretenbergService.generateHashArray([
      new Fr(commitment % Fr.MODULUS),
      new Fr(bliding % Fr.MODULUS),
    ]);
    return nullifier;
  }
}
