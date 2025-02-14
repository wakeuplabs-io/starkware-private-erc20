import { CommitmentEvent, CommitmentPayload, Note } from "@/interfaces";
import { Provider, selector, events as Events, CallData } from "starknet";
import { EVENTS_CHUNK } from "node_modules/starknet-types-07/dist/types/api/components";
import {
  PRIVATE_ERC20_ABI,
  PRIVATE_ERC20_CONTRACT_ADDRESS,
} from "@/shared/config/constants";
import { BarretenbergService } from "./bb.service";
import { AccountService } from "./account.service";
import { CipherService } from "./cipher.service";
import { provider } from "@/shared/config/rpc";
import { DefinitionsService } from "./definitions.service";

export class NotesService {
  private provider: Provider;

  constructor(provider: Provider) {
    this.provider = provider;
  }

  async getNotes(): Promise<{
    notesArray: Note[];
    notesMap: Map<bigint, Note>;
    spendingTrackersMap: Map<string, string>;
  }> {
    const toBlock = await this.provider.getBlock("latest");
    const fromBlock = await this.getCacheLatestBlock();

    // fetch new events and merge with cache
    const { notes: cachedNotes, spendingTrackers: cachedSpendingTrackers } =
      await this.fetchFromLocalStorage();
    const { notes: newNotes, spendingTrackers: newSpendingTrackers } =
      await this.fetchFromBlockchain(fromBlock, toBlock.block_number);

    const notes = [...cachedNotes, ...newNotes];
    const spendingTrackers = [
      ...cachedSpendingTrackers,
      ...newSpendingTrackers,
    ];

    // turn into map and back to array to avoid duplicates
    const notesMap = new Map(notes.map((note) => [note.commitment, note]));
    const spendingTrackersMap = new Map(spendingTrackers.map((st) => [st, st]));

    // iterate over notes and nullify those that have already been used
    Array.from(notesMap.values())
      .filter(
        (note) => note.value !== undefined && note.trackerHash !== undefined
      )
      .map((note) => {
        if (spendingTrackersMap.has(note.trackerHash!.toString())) {
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
    await this.setCachedSpendingTrackers(Array.from(spendingTrackersMap.values()));
    await this.setCacheLatestBlock(toBlock.block_number);

    return { notesArray, notesMap, spendingTrackersMap };
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

  private setCachedSpendingTrackers(st: string[]) {
    localStorage.setItem("spendingTrackers", JSON.stringify(st));
  }

  private async fetchFromLocalStorage(): Promise<{
    notes: Note[];
    spendingTrackers: string[];
  }> {
    const notes = JSON.parse(
      localStorage.getItem("notes") || "[]",
      (_, value) =>
        typeof value === "string" && value.endsWith("n")
          ? BigInt(value.slice(0, -1))
          : value
    );
    const spendingTrackers = JSON.parse(
      localStorage.getItem("spendingTrackers") || "[]"
    );

    return { notes, spendingTrackers };
  }

  private async fetchFromBlockchain(
    fromBlock: number,
    toBlock: number
  ): Promise<{ notes: Note[]; spendingTrackers: string[] }> {
    const commitments: CommitmentEvent[] = [];
    const spendingTrackers: string[] = [];
    let continuationToken: string | undefined;

    do {
      const eventsResponse: EVENTS_CHUNK =
        await this.provider.channel.getEvents({
          address: PRIVATE_ERC20_CONTRACT_ADDRESS,
          keys: [
            [
              selector.getSelectorFromName("NewCommitment"),
              selector.getSelectorFromName("NewSpendingTracker"),
            ],
          ],
          from_block: { block_number: fromBlock },
          to_block: { block_number: toBlock },
          chunk_size: 100,
          continuation_token: continuationToken,
        });

      const eventsParsed = Events.parseEvents(
        eventsResponse.events,
        Events.getAbiEvents(PRIVATE_ERC20_ABI),
        CallData.getAbiStruct(PRIVATE_ERC20_ABI),
        CallData.getAbiEnum(PRIVATE_ERC20_ABI)
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

      // retrieve spending trackers
      const partialSpendingTrackers = eventsParsed
        .filter(
          (event) =>
            event["contracts::privado::privado::Privado::NewSpendingTracker"]
        )
        .map((event) => {
          const data =
            event["contracts::privado::privado::Privado::NewSpendingTracker"];
          return data.spending_tracker?.toString() || "";
        });

      commitments.push(...partialNewCommitments);
      spendingTrackers.push(...partialSpendingTrackers);

      continuationToken = eventsResponse.continuation_token;
    } while (continuationToken);

    // process notes and spendingTrackers
    const account = await AccountService.getAccount();

    const notesExpanded: Note[] = await Promise.all(
      commitments.map(async (commitmentEvent) => {
        try {
          const { commitment, encryptedOutput, index }: Note = commitmentEvent;

          const decrypted: CommitmentPayload = JSON.parse(
            await CipherService.decrypt(
              encryptedOutput,
              account.viewer.publicKey,
              account.viewer.privateKey
            )
          );

          const tracker = await DefinitionsService.generateCommitmentTracker(
            commitment,
            decrypted.bliding
          );
          const trackerHash = await BarretenbergService.generateHash(tracker);

          return {
            commitment,
            encryptedOutput,
            index,
            value: BigInt("0x" + decrypted.value),
            bliding: BigInt("0x" + decrypted.bliding),
            trackerHash: trackerHash,
          };
        } catch (error) {
          console.log("commitment", error);
          const { commitment, encryptedOutput, index }: Note = commitmentEvent;
          return { commitment, encryptedOutput, index };
        }
      })
    );

    return { notes: notesExpanded, spendingTrackers };
  }
}

export const notesService = new NotesService(provider);
