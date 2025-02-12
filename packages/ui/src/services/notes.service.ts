import { CommitmentEvent, DecryptedOutput, Note } from "@/interfaces";
import { Provider, selector, events as Events, CallData } from "starknet";
import { EVENTS_CHUNK } from "node_modules/starknet-types-07/dist/types/api/components";
import { PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";
import privateTokenAbi from "@/abi/private-erc20.abi";
import { BarretenbergService } from "./bb.service";
import { AccountService } from "./account.service";
import { CipherService } from "./cipher.service";

export class NotesService {
  private provider: Provider;

  constructor(provider: Provider) {
    this.provider = provider;
  }

  async getNotes(): Promise<Note[]> {
    const toBlock = await this.provider.getBlock("latest");
    const fromBlock = await this.getCacheLatestBlock();

    // fetch new events and merge with cache
    const { notes: cachedNotes, nullifiers: cachedNullifiers } =
      await this.fetchFromLocalStorage();
    const { notes: newNotes, nullifiers: newNullifiers } =
      await this.fetchFromBlockchain(fromBlock, toBlock.block_number);

    const notes = [...cachedNotes, ...newNotes];
    const nullifiers = [...cachedNullifiers, ...newNullifiers];

    // turn into map and back to array to avoid duplicates
    const notesMap = new Map(notes.map((note) => [note.commitment, note]));
    const nullifiersMap = new Map(
      nullifiers.map((nullifier) => [nullifier, nullifier])
    );

    // iterate over notes and nullify those that have already been used
    Array.from(notesMap.values())
      .filter(
        (note) => note.value !== undefined && note.nullifierHash !== undefined
      )
      .map((note) => {
        if (nullifiersMap.has(note.nullifierHash!.toString())) {
          notesMap.set(note.commitment, {
            ...note,
            spent: true,
          });
        }
      });

    // back to array
    const notesArray = Array.from(notesMap.values());

    // save cache
    await this.setCacheNotes(notesArray);
    await this.setCachedNullifiers(Array.from(nullifiersMap.values()));
    await this.setCacheLatestBlock(toBlock.block_number);

    return notesArray;
  }

  private getCacheLatestBlock(): number {
    return parseInt(localStorage.getItem("lastScannedBlock") || "500000", 10);
  }

  private setCacheLatestBlock(block: number) {
    localStorage.setItem("lastScannedBlock", block.toString());
  }

  private setCacheNotes(notes: Note[]) {
    localStorage.setItem(
      "notes",
      JSON.stringify(notes, (_, value) =>
        typeof value === "bigint" ? value.toString() + "n" : value
      )
    );
  }

  private setCachedNullifiers(nullifiers: string[]) {
    localStorage.setItem("nullifiers", JSON.stringify(nullifiers));
  }

  private async fetchFromLocalStorage(): Promise<{
    notes: Note[];
    nullifiers: string[];
  }> {
    const notes = JSON.parse(
      localStorage.getItem("notes") || "[]",
      (_, value) =>
        typeof value === "string" && value.endsWith("n")
          ? BigInt(value.slice(0, -1))
          : value
    );
    const nullifiers = JSON.parse(localStorage.getItem("nullifiers") || "[]");

    return { notes, nullifiers };
  }

  private async fetchFromBlockchain(
    fromBlock: number,
    toBlock: number
  ): Promise<{ notes: Note[]; nullifiers: string[] }> {
    const newCommitmentHash = selector.getSelectorFromName("NewCommitment");
    const newNullifierHash = selector.getSelectorFromName("NewNullifier");
    const abiEvents = Events.getAbiEvents(privateTokenAbi);
    const abiStructs = CallData.getAbiStruct(privateTokenAbi);
    const abiEnums = CallData.getAbiEnum(privateTokenAbi);

    const commitments: CommitmentEvent[] = [];
    const nullifiers: string[] = [];
    let continuationToken: string | undefined;

    do {
      const eventsResponse: EVENTS_CHUNK =
        await this.provider.channel.getEvents({
          address: PRIVATE_ERC20_CONTRACT_ADDRESS,
          keys: [[newCommitmentHash, newNullifierHash]],
          from_block: { block_number: fromBlock },
          to_block: { block_number: toBlock },
          chunk_size: 100,
          continuation_token: continuationToken,
        });

      const eventsParsed = Events.parseEvents(
        eventsResponse.events,
        abiEvents,
        abiStructs,
        abiEnums
      );

      // retrieve commitments
      const partialNewCommitments = eventsParsed
        .filter(
          (event) =>
            event["contracts::privado::privado::Privado::NewCommitment"]
        )
        .map((event) => {
          const { commitment, output_enc, index } =
            event["contracts::privado::privado::Privado::NewCommitment"];
          return {
            commitment: BigInt(commitment.toString()),
            encryptedOutput: output_enc.toString(),
            index: BigInt(index.toString()),
          };
        });

      // retrieve nullifiers
      const partialNullifierHashes = eventsParsed
        .filter(
          (event) => event["contracts::privado::privado::Privado::NewNullifier"]
        )
        .map((event) => {
          const data =
            event["contracts::privado::privado::Privado::NewNullifier"];
          return data.nullifier_hash?.toString() || "";
        });

      commitments.push(...partialNewCommitments);
      nullifiers.push(...partialNullifierHashes);

      continuationToken = eventsResponse.continuation_token;
    } while (continuationToken);

    // process notes and nullifiers
    const account = await AccountService.getAccount();
    const notesExpanded: Note[] = await Promise.all(
      commitments.map(async (commitmentEvent) => {
        try {
          const { commitment, encryptedOutput, index }: Note = commitmentEvent;

          const decrypted: DecryptedOutput = JSON.parse(
            await CipherService.decrypt(
              encryptedOutput,
              account.publicKey,
              account.privateKey
            )
          );
          
          const nullifier = await BarretenbergService.generateNullifier(
            commitment,
            account.privateKey,
            index
          );
          const nullifierHash =
            await BarretenbergService.generateHash(nullifier);

          return {
            commitment,
            encryptedOutput,
            index,
            value: BigInt("0x" + decrypted.value),
            bliding: BigInt("0x" + decrypted.bliding),
            nullifierHash: nullifierHash,
          };
        } catch (error) {
          const { commitment, encryptedOutput, index }: Note = commitmentEvent;
          return { commitment, encryptedOutput, index };
        }
      })
    );

    return { notes: notesExpanded, nullifiers };
  }
}
