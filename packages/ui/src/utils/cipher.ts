import nacl from "tweetnacl";
import naclUtil from "tweetnacl-util";
import { Fr, Barretenberg } from "@aztec/bb.js"; // Asegúrate de importar Fr de la biblioteca correcta

let bbInstance: Barretenberg | null = null;

function encryptNote(
  note: { value: number },
  receiverPublicKey: Uint8Array | string,
  senderPrivateKey: Uint8Array
): string {
  if(typeof receiverPublicKey === "string") {
    receiverPublicKey = naclUtil.decodeBase64(receiverPublicKey);
  }
  const message = naclUtil.decodeUTF8(JSON.stringify(note));
  const nonce = nacl.randomBytes(nacl.box.nonceLength);
  const encrypted = nacl.box(message, nonce, receiverPublicKey, senderPrivateKey);

  if (!encrypted) throw new Error("Encryption failed");

  const fullEncrypted = new Uint8Array([...nonce, ...encrypted]);
  return naclUtil.encodeBase64(fullEncrypted);
}

function decryptNote(
  encryptedString: string,
  receiverPrivateKey: Uint8Array,
  senderPublicKey: Uint8Array
): { value: number } {
  try {
    const fullEncrypted = naclUtil.decodeBase64(encryptedString);

    const nonce = fullEncrypted.slice(0, nacl.box.nonceLength);
    const encryptedData = fullEncrypted.slice(nacl.box.nonceLength);

    const decrypted = nacl.box.open(encryptedData, nonce, senderPublicKey, receiverPrivateKey);

    if (!decrypted) throw new Error("Failed to decrypt");

    return JSON.parse(naclUtil.encodeUTF8(decrypted));
  } catch (error) {
    throw new Error("Invalid encrypted string format");
  }
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
