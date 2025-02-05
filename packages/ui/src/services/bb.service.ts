import { Fr, BarretenbergSync } from "@aztec/bb.js";
import { CipherService } from "./cipher.service";

class BarretenbergService {
  private static instance: BarretenbergSync | null = null;

  static async initialize() {
    if (!this.instance) {
      this.instance = await BarretenbergSync.new();
    }
  }

  static getInstance(): BarretenbergSync {
    if (!this.instance) {
      throw new Error("BarretenbergSync instance is not ready yet");
    }
    return this.instance;
  }

  static generateHash(input: string): string {
    const bb = this.getInstance();
    const inputFr = new Fr(BigInt(input));
    return bb.poseidon2Hash([inputFr]).toString();
  }

  static generateHashArray(inputs: Fr[]): bigint {
    const bb = this.getInstance();
    return BigInt(bb.poseidon2Hash(inputs).toString());
  }

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
    const bb = this.getInstance();

    const randomBytes = crypto.getRandomValues(new Uint8Array(16)); // 16 bytes for up to 128-bit range
    const bliding = BigInt('0x' + [...randomBytes].map(b => b.toString(16).padStart(2, '0')).join(''));
  
    return {
      commitment: BigInt(
        bb.poseidon2Hash([new Fr(toAddress), new Fr(value)]).toString()
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

// TODO: move into service
(async () => {
  await BarretenbergService.initialize();
})();

export { BarretenbergService };
