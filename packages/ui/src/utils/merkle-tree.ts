import { BarretenbergService } from "@/services/bb.service";
import { Fr } from "@aztec/bb.js";

const DEPTH = 4;
const MAX_LEAVES = 2 ** DEPTH;
const ZERO_LEAF = "0x00";

export class MerkleTree {
  private leaves: string[];
  private nextIndex: number;

  constructor() {
    this.leaves = new Array(MAX_LEAVES).fill(ZERO_LEAF);
    this.nextIndex = 0;
  }

  async addCommitment(commitment: string) {
    if (this.nextIndex >= MAX_LEAVES) {
      throw new Error("Merkle tree is full. No more leaves can be added.");
    }
    this.leaves[this.nextIndex] = commitment;
    this.nextIndex++;
    await this.recalculateTree();
  }

  private levels: string[][] = [];

  private async recalculateTree() {
    this.levels = [ [...this.leaves] ];

    let currentLevel = this.levels[0];
    let size = currentLevel.length;

    while (size > 1) {
      const nextSize = Math.ceil(size / 2);
      const nextLevel: string[] = new Array(nextSize);

      for (let i = 0; i < nextSize; i++) {
        const left = currentLevel[2*i] ?? ZERO_LEAF;
        const right = currentLevel[2*i + 1] ?? left;
        const leftFr = new Fr(BigInt(left));
        const rightFr = new Fr(BigInt(right));

        const hash = await BarretenbergService.generateHashArray([leftFr, rightFr]);

        nextLevel[i] = hash.toString();
      }

      this.levels.push(nextLevel);
      size = nextSize;
      currentLevel = nextLevel;
    }
  } 



  getRoot(): string {
    if (this.levels.length === 0) {
      return ZERO_LEAF; 
    }
    const topLevel = this.levels[this.levels.length - 1];
    return topLevel.length > 0 ? topLevel[0] : ZERO_LEAF;
  }

  
  getProof(commitment: string): { path: string[]; directionSelector: boolean[] } | null {
    const index = this.leaves.indexOf(commitment);
    if (index === -1) return null;

    const path: string[] = [];
    const directionSelector: boolean[] = [];

    let currentIndex = index;

    for (let level = 0; level < DEPTH; level++) {
      if (level >= this.levels.length - 1) break;

      const levelNodes = this.levels[level];
      const isRightNode = (currentIndex % 2 === 1);

      const pairIndex = isRightNode ? currentIndex - 1 : currentIndex + 1;

      if (pairIndex < levelNodes.length) {
        path.push(levelNodes[pairIndex]);
      } else {
        path.push(ZERO_LEAF);
      }
      directionSelector.push(isRightNode);

      currentIndex = Math.floor(currentIndex / 2);
    }

    return { path, directionSelector };
  }

}
