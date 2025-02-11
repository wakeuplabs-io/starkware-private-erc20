// useEvents.ts
import { useEffect, useState, useCallback, useRef } from "react";
import { selector, events as Events, CallData, Provider } from "starknet";
import { useProvider } from "@starknet-react/core";
import { CommitmentEvent } from "@/interfaces";
import { PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";
import privateTokenAbi from "@/abi/private-erc20.abi";
import NoteCacheService from "@/services/note.cache.service";
import { EVENTS_CHUNK } from "node_modules/starknet-types-07/dist/types/api/components";

const abiEvents = Events.getAbiEvents(privateTokenAbi);
const abiStructs = CallData.getAbiStruct(privateTokenAbi);
const abiEnums = CallData.getAbiEnum(privateTokenAbi);

const LOCAL_STORAGE_KEY = "lastScannedBlock";
const newCommitmentHash = selector.getSelectorFromName("NewCommitment");
const newNullifierHash = selector.getSelectorFromName("NewNullifier");

interface EventsState {
  commitments: CommitmentEvent[];
  nullifierHashes: string[];
  error: string | null;
  isLoading: boolean;
}

export const useEvents = () => {
  const [state, setState] = useState<EventsState>({
    commitments: [],
    nullifierHashes: [],
    error: null,
    isLoading: false,
  });

  const { provider } = useProvider() as { provider: Provider };

  const [lastScannedBlock, setLastScannedBlock] = useState<number>(() => {
    const storedBlock = localStorage.getItem(LOCAL_STORAGE_KEY);
    return storedBlock ? parseInt(storedBlock, 10) : 500_000;
  });

  const isFetchingRef = useRef(false);

  const refetchEvents = useCallback(async () => {
    if (isFetchingRef.current) return;
    isFetchingRef.current = true;

    setState((prev) => ({
      ...prev,
      isLoading: true,
      error: null,
    }));

    try {
      let continuationToken: string | undefined = undefined;
      const fromBlock = lastScannedBlock || 500_000;
      const newCommitments: CommitmentEvent[] = [];
      const newNullifierHashes: string[] = [];
      const currentBlock = await provider.getBlock("latest");

      do {
        const eventsResponse: EVENTS_CHUNK = await provider.channel.getEvents({
          address: PRIVATE_ERC20_CONTRACT_ADDRESS,
          keys: [[newCommitmentHash, newNullifierHash]],
          from_block: { block_number: fromBlock },
          to_block: "latest",
          chunk_size: 100,
          continuation_token: continuationToken,
        });

        const eventsParsed = Events.parseEvents(
          eventsResponse.events,
          abiEvents,
          abiStructs,
          abiEnums
        );

        const partialNewCommitments = eventsParsed
          .filter((event) => event["contracts::privado::privado::Privado::NewCommitment"])
          .map((event) => {
            const { commitment, output_enc, index } =
              event["contracts::privado::privado::Privado::NewCommitment"];
            return {
              commitment: BigInt(commitment.toString()),
              encryptedOutput: output_enc.toString(),
              index: BigInt(index.toString()),
            };
          });

        const partialNullifierHashes = eventsParsed
          .filter((event) => event["contracts::privado::privado::Privado::NewNullifier"])
          .map((event) => {
            const data = event["contracts::privado::privado::Privado::NewNullifier"];
            return data.nullifier_hash?.toString() || "";
          });

        newCommitments.push(...partialNewCommitments);
        newNullifierHashes.push(...partialNullifierHashes);

        continuationToken = eventsResponse.continuation_token;
      } while (continuationToken);
      
      await NoteCacheService.setCommitments(newCommitments);
      await NoteCacheService.setNullifierHashes(newNullifierHashes);

      const allSavedCommitments = await NoteCacheService.getCommitments();
      const allSavedNullifierHashes = await NoteCacheService.getNullifierHashes();

      setState({
        commitments: allSavedCommitments,
        nullifierHashes: allSavedNullifierHashes,
        error: null,
        isLoading: false,
      });

      localStorage.setItem(LOCAL_STORAGE_KEY, currentBlock.block_number.toString());
      setLastScannedBlock(currentBlock.block_number);
    } catch (err) {
      console.error("Error fetching events:", err);
      setState((prev) => ({
        ...prev,
        error: "Failed to fetch events",
        isLoading: false,
      }));
    } finally {
      isFetchingRef.current = false;
    }
  }, [provider, lastScannedBlock]);

  useEffect(() => {
    refetchEvents();
  }, [refetchEvents]);

  return {
    ...state,
    lastScannedBlock,
    refetchEvents,
  };
};
