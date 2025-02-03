import nacl from "tweetnacl";
import naclUtil from "tweetnacl-util";

class CipherService {
  static encryptNote(
    note: { value: number },
    receiverPublicKey: Uint8Array | string,
    senderPrivateKey: Uint8Array
  ): string {
    if (typeof receiverPublicKey === "string") {
      receiverPublicKey = naclUtil.decodeBase64(receiverPublicKey);
    }
    const message = naclUtil.decodeUTF8(JSON.stringify(note));
    const nonce = nacl.randomBytes(nacl.box.nonceLength);
    const encrypted = nacl.box(message, nonce, receiverPublicKey, senderPrivateKey);

    if (!encrypted) throw new Error("Encryption failed");

    const fullEncrypted = new Uint8Array([...nonce, ...encrypted]);
    return naclUtil.encodeBase64(fullEncrypted);
  }

  static decryptNote(
    encryptedString: string,
    receiverPrivateKey: Uint8Array,
    senderPublicKey: Uint8Array
  ): { value: number } {
    const fullEncrypted = naclUtil.decodeBase64(encryptedString);
    const nonce = fullEncrypted.slice(0, nacl.box.nonceLength);
    const encryptedData = fullEncrypted.slice(nacl.box.nonceLength);

    const decrypted = nacl.box.open(encryptedData, nonce, senderPublicKey, receiverPrivateKey);
    if (!decrypted) throw new Error("Failed to decrypt");

    return JSON.parse(naclUtil.encodeUTF8(decrypted));
  }
}

export { CipherService };
