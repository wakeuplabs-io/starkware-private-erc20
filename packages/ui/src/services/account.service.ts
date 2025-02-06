import { Fr } from "@aztec/bb.js";
import { BarretenbergService } from "./bb.service";
import sodium from "libsodium-wrappers";

const FIELD_SIZE = 100;

class AccountService {
  static getAccount() {
    try {
      return this._load();
    } catch {
      return this._generate();
    }
  }

  private static async _generate(): Promise<{
    publicKey: bigint;
    privateKey: bigint;
    address: bigint;
  }> {
    await sodium.ready;
    const keypair = await sodium.crypto_box_keypair();
    const publicKey = BigInt(sodium.to_hex(keypair.publicKey));
    const privateKey = BigInt(sodium.to_hex(keypair.privateKey));
    const address = BarretenbergService.generateHashArray([new Fr(privateKey)]);

    console.log("generate", publicKey, privateKey, address);

    localStorage.setItem("PrivateKey", privateKey.toString(16));
    localStorage.setItem("PublicKey", publicKey.toString(16));
    localStorage.setItem("Address", address.toString(16));

    return { publicKey, privateKey, address };
  }

  private static async _load(): Promise<{
    publicKey: bigint;
    privateKey: bigint;
    address: bigint;
  }> {
    await sodium.ready;

    const privateKeyString = localStorage.getItem("PrivateKey");
    const publicKeyString = localStorage.getItem("PublicKey");
    const addressString = localStorage.getItem("Address");

    if (!privateKeyString || !publicKeyString || !addressString) {
      throw new Error("Could not load account");
    }

    const privateKey = BigInt(privateKeyString);
    const publicKey = BigInt(publicKeyString);
    const address = BigInt(addressString);

    return { publicKey, privateKey, address };
  }
}

export { AccountService };
