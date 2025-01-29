import { SHA256 } from "crypto-js";
import nacl from "tweetnacl";
import naclUtil from "tweetnacl-util";

function encryptNote(note: { value: number}, receiverPublicKey: Uint8Array, senderPrivateKey: Uint8Array) {
  const message = naclUtil.decodeUTF8(JSON.stringify(note));
  const nonce = nacl.randomBytes(nacl.box.nonceLength);

  const encrypted = nacl.box(message, nonce, receiverPublicKey, senderPrivateKey);
  
  return {
    encryptedData: naclUtil.encodeBase64(encrypted),
    nonce: naclUtil.encodeBase64(nonce),
  };
}

function decryptNote(encryptedNote: { encryptedData: string; nonce: string }, receiverPrivateKey: Uint8Array, senderPublicKey: Uint8Array) {
  const encryptedData = naclUtil.decodeBase64(encryptedNote.encryptedData);
  const nonce = naclUtil.decodeBase64(encryptedNote.nonce);

  const decrypted = nacl.box.open(encryptedData, nonce, senderPublicKey, receiverPrivateKey);

  if (!decrypted) throw new Error("Failed to decrypt");

  return JSON.parse(naclUtil.encodeUTF8(decrypted));
}

function generateCommitment(value: number, address: string, num: number): string {
  return SHA256(`${value}-${address}-${num}`).toString();
}

export { encryptNote, decryptNote, generateCommitment };
