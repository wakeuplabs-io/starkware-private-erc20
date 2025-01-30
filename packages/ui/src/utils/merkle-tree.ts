import { Fr } from "@aztec/bb.js";
import { getBBInstance } from "./cipher";

export class MerkleTree {
  private levels: string[][] = [];
  private commitments: string[] = [];

  constructor() {}

  async addCommitment(commitment: string) {
    this.commitments.push(commitment);
    await this.recalculateTree();
  }

  private async recalculateTree() {
    const bb = await getBBInstance();
    let currentLevel = [...this.commitments];

    this.levels = [currentLevel];

    while (currentLevel.length > 1) {
      const nextLevel = [];
      for (let i = 0; i < currentLevel.length; i += 2) {
        const left = currentLevel[i];
        const right = currentLevel[i + 1] || left;

        const hash = await bb.poseidon2Hash([
          new Fr(BigInt(left)),
          new Fr(BigInt(right)),
        ]);
        nextLevel.push(hash.toString());
      }
      currentLevel = nextLevel;
      this.levels.push(currentLevel);
    }
  }

  getRoot(): string {
    return this.levels.length > 0 ? this.levels[this.levels.length - 1][0] : "";
  }
}
