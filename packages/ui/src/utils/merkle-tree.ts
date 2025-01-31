import { Fr } from "@aztec/bb.js";
import { getBBInstance } from "./cipher";

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
    await this.recalcFull();
  }

  private levels: string[][] = [];

  private async recalcFull() {
    const bb = await getBBInstance();

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

        // Noir pone left en el índice menor y right en el mayor

        const hash = await bb.poseidon2Hash([leftFr, rightFr]);
        if(left == "0x16b640ef5bf81ef5ea750c244eb9e53370709adba1fc6c37f385fa6a740161e5"){
          console.log("left", left);
          console.log("right", right);
          console.log("result", hash.toString());
        }

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
        path.push(ZERO_LEAF); // Asegurar que sea 0 si no hay par
      }
      directionSelector.push(isRightNode);

      currentIndex = Math.floor(currentIndex / 2);
    }

    return { path, directionSelector };
  }

}
