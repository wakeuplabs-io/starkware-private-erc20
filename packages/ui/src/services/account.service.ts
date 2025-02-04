import { Fr } from "@aztec/bb.js";
import { BarretenbergService } from "./bb.service";

class AccountService {
  static secretAccount: string | null = null;
  private static nullifier: number = 0;

  static generateSecretAccount(): string {
    const array = new Uint8Array(20);
    window.crypto.getRandomValues(array);

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
    const secretAccount = this.getSecretAccount();
    const receiverAccount = BarretenbergService.generateHashArray([
      new Fr(BigInt(secretAccount)),
      new Fr(BigInt(this.nullifier)),
    ]);

    this.nullifier++;

    return {
      address: receiverAccount.toString(),
      nullifier: (this.nullifier - 1).toString(),
    };
  }
}

export { AccountService };
