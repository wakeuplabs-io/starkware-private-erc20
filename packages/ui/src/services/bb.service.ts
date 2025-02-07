import { Fr, BarretenbergSync } from "@aztec/bb.js";
import { CipherService } from "./cipher.service";

class BarretenbergService {
  private static instance: BarretenbergSync | null = null;

  static async getInstance(): Promise<BarretenbergSync> {
    if (!this.instance) {
      this.instance = await BarretenbergSync.new();
    }
    return this.instance;
  }

  static async generateHash(input: bigint): Promise<bigint> {
    const bb = await this.getInstance();
    return BigInt(bb.poseidon2Hash([new Fr(input)]).toString());
  }

  static async generateHashArray(inputs: Fr[]): Promise<bigint> {
    const bb = await this.getInstance();
    return BigInt(bb.poseidon2Hash(inputs).toString());
  }

  // "0xc87c78ad8a509a532b761404065873cf"

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
    const bb = await this.getInstance();

    const randomBytes = crypto.getRandomValues(new Uint8Array(16)); // 16 bytes for up to 128-bit range
    const bliding = BigInt(
      "0x" +
        [...randomBytes].map((b) => b.toString(16).padStart(2, "0")).join("")
    );

    return {
      commitment: BigInt(
        bb
          .poseidon2Hash([new Fr(toAddress), new Fr(value), new Fr(bliding)])
          .toString()
      ),
      encOutput: await CipherService.encrypt(
        JSON.stringify({
          bliding: bliding.toString(16),
          value: value.toString(16),
        }),
        toPublicKey
      ),
      bliding,
      value,
    };
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
}

export { BarretenbergService };
