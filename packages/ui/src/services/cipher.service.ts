import sodium from "libsodium-wrappers";

class CipherService {
  static async encrypt(
    data: string,
    publicKey: bigint
  ): Promise<string> {
    await sodium.ready;
    const message = sodium.from_string(data);
    const encrypted = sodium.crypto_box_seal(message, sodium.from_hex(publicKey.toString(16)));
    return sodium.to_base64(encrypted);
  }

  static async decrypt(
    data: string,
    publicKey: bigint,
    privateKey: bigint
  ): Promise<string> {
    await sodium.ready;
    const encrypted = sodium.from_base64(data);
    const decrypted = sodium.crypto_box_seal_open(
      encrypted,
      sodium.from_hex(publicKey.toString(16)),
      sodium.from_hex(privateKey.toString(16))
    );

    return sodium.to_string(decrypted);
  }
}

export { CipherService };
