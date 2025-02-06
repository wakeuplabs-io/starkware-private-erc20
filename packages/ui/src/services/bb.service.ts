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

  static async generateHash(input: string): Promise<string> {
    const bb = await this.getInstance();
    return bb.poseidon2Hash([new Fr(BigInt(input))]).toString();
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

    // const randomBytes = crypto.getRandomValues(new Uint8Array(16)); // 16 bytes for up to 128-bit range
    // const bliding = BigInt('0x' + [...randomBytes].map(b => b.toString(16).padStart(2, '0')).join(''));
    const bliding = BigInt("0xc87c78ad8a509a532b761404065873cf");
    console.log("abc", BigInt(
      bb.poseidon2Hash([new Fr(toAddress), new Fr(10n), new Fr(bliding)]).toString()
    ).toString(16));
    "1c19b4e2cde7662f125ca488852bf75cd26049bb4027c19847f04b8d9abe747b"
    // 2c99d2989f0f9f45203d0f40a2296c338b6b34e86464ed1fef08b245b684d64d

    return {
      commitment: BigInt(
        bb.poseidon2Hash([new Fr(toAddress), new Fr(value), new Fr(bliding)]).toString()
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

  // TODO: move outside
  static convertToField(value: string | number | bigint): Fr {
    let bigIntValue: bigint;

    if (typeof value === "string") {
      bigIntValue = value.startsWith("0x")
        ? BigInt(value)
        : BigInt(parseInt(value, 10));
    } else {
      bigIntValue = BigInt(value);
    }

    return new Fr(bigIntValue % Fr.MODULUS);
  }
}

export { BarretenbergService };
