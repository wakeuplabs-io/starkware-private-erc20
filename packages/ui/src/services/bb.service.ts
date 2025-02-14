import { Fr, BarretenbergSync } from "@aztec/bb.js";

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
}

export { BarretenbergService };
