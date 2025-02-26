import { CommitmentEvent, CommitmentPayload, Note } from "@/interfaces";
import { Provider, selector, events as Events, CallData } from "starknet";
import { EVENTS_CHUNK } from "node_modules/starknet-types-07/dist/types/api/components";
import {
  ENIGMA_ABI,
  ENIGMA_CONTRACT_ADDRESS,
} from "@/shared/config/constants";
import { AccountService } from "./account.service";
import { CipherService } from "./cipher.service";
import { provider } from "@/shared/config/rpc";
import { DefinitionsService } from "./definitions.service";
import { parse, stringify } from "@/lib/utils";

export class NotesService {
  private provider: Provider;

  constructor(provider: Provider) {
    this.provider = provider;
  }

  async getNotes(): Promise<{
    notesArray: Note[];
    notesMap: Map<bigint, Note>;
    nullifiersMap: Map<string, string>;
  }> {
    // invalidate cache on new deployment
    if (this.isNewDeployment()) {
      this.invalidateCache();
    }

    const toBlock = await this.provider.getBlock("latest");
    const fromBlock = await this.getCacheLatestBlock();

    // fetch new events and merge with cache
    const { notes: cachedNotes, nullifiers: cachedNullifiers } =
      await this.fetchFromLocalStorage();
    const { notes: newNotes, nullifiers: newNullifiers } =
      await this.fetchFromBlockchain(fromBlock, toBlock.block_number);

    const notes = [...cachedNotes, ...newNotes];
    const nullifiers = [
      ...cachedNullifiers,
      ...newNullifiers,
    ];

    // turn into map and back to array to avoid duplicates
    const notesMapByIndex = new Map(notes.map((note) => [note.index, note]));
    const nullifiersMap = new Map(nullifiers.map((st) => [st, st]));

    // iterate over notes and nullify those that have already been used
    Array.from(notesMapByIndex.values())
      .filter(
        (note) => note.value !== undefined && note.nullifier !== undefined
      )
      .map((note) => {
        if (nullifiersMap.has(note.nullifier!.toString())) {
          notesMapByIndex.set(note.index, {
            ...note,
            spent: true,
          });
        }
      });

    // back to array
    const notesArray = Array.from(notesMapByIndex.values());
    const notesMap = new Map(notesArray.map((note) => [note.commitment, note]));

    // save cache
    await this.setCacheNotes(notesArray);
    await this.setCachedNullifiers(
      Array.from(nullifiersMap.values())
    );
    await this.setCacheLatestBlock(toBlock.block_number);

    return { notesArray, notesMap, nullifiersMap };
  }

  private isNewDeployment(): boolean {
    return localStorage.getItem("DEPLOYMENT_ID") !== import.meta.env.VITE_DEPLOYMENT_ID;
  }

  private invalidateCache() {
    localStorage.removeItem("notes");
    localStorage.removeItem("nullifiers");
    localStorage.removeItem("lastScannedBlock");

    localStorage.setItem("DEPLOYMENT_ID", import.meta.env.VITE_DEPLOYMENT_ID);
  }

  private getCacheLatestBlock(): number {
    return parseInt(localStorage.getItem("lastScannedBlock") || "500000", 10);
  }

  private setCacheLatestBlock(block: number) {
    localStorage.setItem("lastScannedBlock", block.toString());
  }

  private setCacheNotes(notes: Note[]) {
    localStorage.setItem("notes", stringify(notes));
  }

  private setCachedNullifiers(st: string[]) {
    localStorage.setItem("nullifiers", stringify(st));
  }

  private async fetchFromLocalStorage(): Promise<{
    notes: Note[];
    nullifiers: string[];
  }> {


    const notes = parse(localStorage.getItem("notes") || "[]");
    const nullifiers = parse(
      localStorage.getItem("nullifiers") || "[]"
    );

    return { notes, nullifiers };
  }

  private async fetchFromBlockchain(
    fromBlock: number,
    toBlock: number
  ): Promise<{ notes: Note[]; nullifiers: string[] }> {
    const commitments: CommitmentEvent[] = [];
    const nullifiers: string[] = [];
    let continuationToken: string | undefined;

    do {
      const eventsResponse: EVENTS_CHUNK =
        await this.provider.channel.getEvents({
          address: ENIGMA_CONTRACT_ADDRESS,
          keys: [
            [
              selector.getSelectorFromName("NewCommitment"),
              selector.getSelectorFromName("NewNullifier"),
            ],
          ],
          from_block: { block_number: fromBlock },
          to_block: { block_number: toBlock },
          chunk_size: 100,
          continuation_token: continuationToken,
        });

      const eventsParsed = Events.parseEvents(
        eventsResponse.events,
        Events.getAbiEvents(ENIGMA_ABI),
        CallData.getAbiStruct(ENIGMA_ABI),
        CallData.getAbiEnum(ENIGMA_ABI)
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

      // retrieve spending nullifiers
      const partialNullifiers = eventsParsed
        .filter(
          (event) =>
            event["contracts::privado::privado::Privado::NewNullifier"]
        )
        .map((event) => {
          const data =
            event["contracts::privado::privado::Privado::NewNullifier"];
          return data.nullifier?.toString() || "";
        });

      commitments.push(...partialNewCommitments);
      nullifiers.push(...partialNullifiers);

      continuationToken = eventsResponse.continuation_token;
    } while (continuationToken);

    // process notes and spendingTrackers
    const account = await AccountService.getAccount();

    const notesExpanded: Note[] = await Promise.all(
      commitments.map(async (commitmentEvent) => {
        try {
          const { commitment, encryptedOutput, index }: Note = commitmentEvent;

          // recover payload
          const decrypted = await CipherService.decrypt(
            encryptedOutput,
            account.viewer.publicKey,
            account.viewer.privateKey
          );
          const payload: CommitmentPayload = parse(decrypted);

          // generate nullifier
          const nullifier = await DefinitionsService.nullifier(
            commitment,
            payload.bliding
          );

          return {
            commitment,
            encryptedOutput,
            index,
            value: payload.value,
            bliding: payload.bliding,
            nullifier: nullifier,
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

export const notesService = new NotesService(provider);
