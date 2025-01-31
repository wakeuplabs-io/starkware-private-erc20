import nacl from "tweetnacl";
import naclUtil from "tweetnacl-util";
import { Fr, Barretenberg } from "@aztec/bb.js"; // Asegúrate de importar Fr de la biblioteca correcta

let bbInstance: Barretenberg | null = null;


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

async function getBBInstance(): Promise<Barretenberg> {
  if (!bbInstance) {
    bbInstance = await Barretenberg.new({});
  }
  return bbInstance;
}

async function generateHash(input: string): Promise<string> {
  const bb = await getBBInstance();
  const inputFr = new Fr(BigInt(input));
  const hashResult = await bb.poseidon2Hash([inputFr]);
  return hashResult.toString();
}


async function generateCommitment(value: number, address: string): Promise<string> {
  const addressFr = new Fr(BigInt(address));
  const valueFr = new Fr(BigInt(value));
  const bb = await Barretenberg.new({});
  const commitmentHash = await bb.poseidon2Hash([addressFr, valueFr]);
  return commitmentHash.toString();
}

function convertToField(value: string | number | bigint): Fr {
  let bigIntValue: bigint;

  if (typeof value === "string") {
    if (value.startsWith("0x")) {
      bigIntValue = BigInt(value);
    } else {
      bigIntValue = BigInt(parseInt(value, 10));
    }
  } else {
    bigIntValue = BigInt(value);
  }

  return new Fr(bigIntValue % Fr.MODULUS);
}

export { encryptNote, decryptNote, generateCommitment, generateHash, getBBInstance, convertToField };
