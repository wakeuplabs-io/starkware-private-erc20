import { Fr } from "@aztec/bb.js";
import { CipherService } from "./cipher.service";
import { BarretenbergService } from "./bb.service";
import { stringify } from "@/lib/utils";
import { ApprovalPayload } from "@/interfaces";

export class DefinitionsService {
  static async note(
    toAddress: bigint,
    toPublicKey: bigint,
    value: bigint
  ): Promise<{
    commitment: bigint;
    encOutput: string;
    bliding: bigint;
    value: bigint;
  }> {
    const randomBytes = crypto.getRandomValues(new Uint8Array(16)); // 16 bytes for up to 128-bit range
    const bliding = BigInt(
      "0x" +
        [...randomBytes].map((b) => b.toString(16).padStart(2, "0")).join("")
    );

    const commitment = await BarretenbergService.generateHashArray([
      new Fr(toAddress % Fr.MODULUS),
      new Fr(value),
      new Fr(bliding),
    ]);

    const encOutput = await CipherService.encrypt(
      stringify({
        bliding: bliding,
        value: value,
      }),
      toPublicKey
    );

    return {
      commitment,
      encOutput,
      bliding,
      value,
    };
  }

  static async nullifier(
    commitment: bigint,
    bliding: bigint
  ): Promise<bigint> {
    const nullifier = await BarretenbergService.generateHashArray([
      new Fr(commitment % Fr.MODULUS),
      new Fr(bliding % Fr.MODULUS),
    ]);
    return nullifier;
  }

  static async allowanceRelationship(
    owner: bigint,
    spender: bigint
  ): Promise<bigint> {
    const relationship = await BarretenbergService.generateHashArray([
      new Fr(owner % Fr.MODULUS),
      new Fr(spender % Fr.MODULUS),
    ]);
    return relationship;
  }

  static async allowanceHash(owner: bigint, spender: bigint, amount: bigint) {
    const hash = await BarretenbergService.generateHashArray([
      new Fr(owner % Fr.MODULUS),
      new Fr(spender % Fr.MODULUS),
      new Fr(amount),
    ]);

    return hash;
  }

  static async approvalEncOutputs(
    payload: ApprovalPayload,
    spenderPublicKey: bigint,
    ownerPublicKey: bigint
  ): Promise<string[]> {
    const [spenderPayload, ownerPayload] = await Promise.all([
      CipherService.encrypt(stringify(payload), spenderPublicKey),
      CipherService.encrypt(stringify(payload), ownerPublicKey),
    ]);

    return [ownerPayload, spenderPayload];
  }
}
