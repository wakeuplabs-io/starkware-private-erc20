import { Fr } from "@aztec/bb.js";
import { BarretenbergService } from "./bb.service";

const FIELD_SIZE = 100;

class Keypair {

}

class AccountService {
  static getPrivateKey(): string {
    if (!this.secretAccount) {
      throw new Error("Secret account has not been generated yet.");
    }
    return this.secretAccount;
  }

  static getPublicKey(): string {
    if (!this.secretAccount) {
      throw new Error("Secret account has not been generated yet.");
    }
    return this.secretAccount;
  }

  static getAddress(): string {
    if (!this.secretAccount) {
      throw new Error("Secret account has not been generated yet.");
    }
    return this.secretAccount;
  }
}

export { AccountService };
