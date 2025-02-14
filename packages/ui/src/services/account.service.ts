import { Fr } from "@aztec/bb.js";
import { BarretenbergService } from "./bb.service";
import sodium from "libsodium-wrappers";
import { parse, stringify } from "@/lib/utils";
import { Account } from "@/interfaces";

class AccountService {
  static async getAccount() {
    try {
      return await this._load();
    } catch (e) {
      return await this._generate();
    }
  }

  private static async _generate(): Promise<Account> {
    await sodium.ready;

    const OwnerKeyPair = await sodium.crypto_box_keypair();
    const ViewerKeyPair = await sodium.crypto_box_keypair();

    const account: Account = {
      owner: {
        address: await BarretenbergService.generateHashArray([
          new Fr(
            BigInt("0x" + sodium.to_hex(OwnerKeyPair.privateKey)) % Fr.MODULUS
          ),
        ]),
        publicKey: BigInt("0x" + sodium.to_hex(OwnerKeyPair.publicKey)),
        privateKey: BigInt("0x" + sodium.to_hex(OwnerKeyPair.privateKey)),
      },
      viewer: {
        publicKey: BigInt("0x" + sodium.to_hex(ViewerKeyPair.publicKey)),
        privateKey: BigInt("0x" + sodium.to_hex(ViewerKeyPair.privateKey)),
      },
    };

    localStorage.setItem("Account", stringify(account));

    return account;
  }

  private static async _load(): Promise<Account> {
    const accountStr = localStorage.getItem("Account");
    if (!accountStr) {
      throw new Error("Could not load account");
    }

    return parse(accountStr) as Account;
  }
}

export { AccountService };
