import { DecryptedOutput } from "@/interfaces";
import sodium from "libsodium-wrappers";
class CipherService {
  static async encryptNote(note: DecryptedOutput, receiverPublicKey: Uint8Array): Promise<string> {
    await sodium.ready;
    const message = sodium.from_string(JSON.stringify(note));
    const encrypted = sodium.crypto_box_seal(message, receiverPublicKey);
    return sodium.to_base64(encrypted);
  }

  static async decryptNote(encryptedString: string, receiverPublicKey: Uint8Array, receiverPrivateKey: Uint8Array): Promise<DecryptedOutput> {
    await sodium.ready;
    const encrypted = sodium.from_base64(encryptedString);
    const decrypted = sodium.crypto_box_seal_open(encrypted, receiverPublicKey, receiverPrivateKey);
    return JSON.parse(sodium.to_string(decrypted));
  }

  static async generateKeyPair(): Promise<{ publicKey: string; secretKey: string }> {
    await sodium.ready;
    const { publicKey, privateKey} = await sodium.crypto_box_keypair();
    const publicKeyString = sodium.to_base64(publicKey);
    const secretKeyString = sodium.to_base64(privateKey);
    localStorage.setItem("PublicKey", publicKeyString);
    localStorage.setItem("SecretKey", secretKeyString);
    return { publicKey: publicKeyString, secretKey: secretKeyString };
  }

  static async getKeyPair(): Promise<{ publicKey: Uint8Array; secretKey: Uint8Array } | null> {
    await sodium.ready;
    
    const publicKeyString = localStorage.getItem("PublicKey");
    const secretKeyString = localStorage.getItem("SecretKey");

    if (!publicKeyString || !secretKeyString) {
      return null;
    }

    return {
      publicKey: sodium.from_base64(publicKeyString),
      secretKey: sodium.from_base64(secretKeyString),
    };
  }
}

export { CipherService };
