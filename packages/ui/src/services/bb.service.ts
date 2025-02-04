
import { Fr, BarretenbergSync } from "@aztec/bb.js";

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

  static generateHashArray(inputs: Fr[]): string {
    const bb = this.getInstance();
    return bb.poseidon2Hash(inputs).toString();
  }

  static generateCommitment(address: string, value: number): string {
    const bb = this.getInstance();
    const addressFr = new Fr(BigInt(address));
    const valueFr = new Fr(BigInt(value));
    return bb.poseidon2Hash([addressFr, valueFr]).toString();
  }


  static convertToField(value: string | number | bigint): Fr {
    let bigIntValue: bigint;

    if (typeof value === "string") {
      bigIntValue = value.startsWith("0x") ? BigInt(value) : BigInt(parseInt(value, 10));
    } else {
      bigIntValue = BigInt(value);
    }

    return new Fr(bigIntValue % Fr.MODULUS);
  }
}
(async () => {
  await BarretenbergService.initialize();
})();
export { BarretenbergService };
