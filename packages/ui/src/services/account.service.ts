import { Fr } from "@aztec/bb.js";
import { BarretenbergService } from "./bb.service";
import sodium from "libsodium-wrappers";

class AccountService {
  static async getAccount() {
    try {
      return await this._load();
    } catch (e) {
      return await this._generate();
    }
  }

  private static async _generate(): Promise<{
    publicKey: bigint;
    privateKey: bigint;
    address: bigint;
  }> {
    await sodium.ready;
    const keypair = await sodium.crypto_box_keypair();
    const publicKey = BigInt("0x" + sodium.to_hex(keypair.publicKey));
    const privateKey = BigInt("0x" + sodium.to_hex(keypair.privateKey));
    const address = await BarretenbergService.generateHashArray([
      new Fr(privateKey % Fr.MODULUS),
    ]);

    localStorage.setItem("PrivateKey", "0x" + privateKey.toString(16));
    localStorage.setItem("PublicKey", "0x" + publicKey.toString(16));
    localStorage.setItem("Address", "0x" + address.toString(16));

    return { publicKey, privateKey, address };
  }

  private static async _load(): Promise<{
    publicKey: bigint;
    privateKey: bigint;
    address: bigint;
  }> {
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
