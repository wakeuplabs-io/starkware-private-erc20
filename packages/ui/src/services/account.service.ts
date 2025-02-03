import { Fr } from "@aztec/bb.js";
import { BarretenbergService } from "./bb.service";

class AccountService {
  static secretAccount: string | null = null;
  private static nullifier: number = 0;

  static generateSecretAccount(): string {
    const array = new Uint8Array(20); // 20 bytes -> 40 hex characters
    window.crypto.getRandomValues(array);

    // Convert bytes to a hex string of exactly 40 characters
    this.secretAccount = "0x" + Array.from(array, (byte) => byte.toString(16).padStart(2, "0")).join("");
    return this.secretAccount;
  }

  static getSecretAccount(): string {
    if (!this.secretAccount) {
      throw new Error("Secret account has not been generated yet.");
    }
    return this.secretAccount;
  }

  static getNextNullifier(): number {
    return this.nullifier;
  }

  static generateReceiverAccount(): { address: string; nullifier: string } {
    const bb = BarretenbergService.getInstance();
    const secretAccount = this.getSecretAccount();
    
    // Convert secretAccount to BigInt safely before hashing
    const receiverAccount = bb.poseidon2Hash([
      new Fr(BigInt(secretAccount)),
      new Fr(BigInt(this.nullifier)),
    ]);

    this.nullifier++; // Increment nullifier for next use

    return {
      address: receiverAccount.toString().slice(0, 40),
      nullifier: (this.nullifier - 1).toString(),
    };
  }
}

export { AccountService };
