import { useEffect, useState } from "react";
import { selector, events as Events, CallData } from "starknet";
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

export const useEvents = () => {
  const [commitments, setCommitments] = useState<CommitmentEvent[]>([]);
  const [nullifierHashes, setNullifierHashes] = useState<string[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const { provider } = useProvider();

  const [lastScannedBlock, setLastScannedBlock] = useState<number | null>(() => {
    const storedBlock = localStorage.getItem(LOCAL_STORAGE_KEY);
    return storedBlock ? parseInt(storedBlock, 10) : 500_000;
  });

  useEffect(() => {
    setIsLoading(true);

    const fetchEvents = async () => {
      try {
        let continuationToken: string | undefined = undefined;
        const latestBlock = lastScannedBlock || 500_000;
        const newCommitments: CommitmentEvent[] = [];
        let allNullifiers: string[] = [];

        let partialNewCommitments : CommitmentEvent[] = [];

        do {
          const eventsResponse: EVENTS_CHUNK = await provider.channel.getEvents({
            address: PRIVATE_ERC20_CONTRACT_ADDRESS,
            keys: [[newCommitmentHash, newNullifierHash]],
            from_block: { block_number: latestBlock },
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

          partialNewCommitments = eventsParsed
            .filter((event) =>
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

          const nullifiersParsed: string[] = eventsParsed
            .filter((event) =>
              event["contracts::privado::privado::Privado::NewNullifier"]
            )
            .map(
              (event) =>
                event["contracts::privado::privado::Privado::NewNullifier"]
                  ?.nullifier_hash?.toString() || ""
            );

          newCommitments.push(...partialNewCommitments);
          allNullifiers = [...allNullifiers, ...nullifiersParsed];
          continuationToken = eventsResponse.continuation_token;
        } while (continuationToken);

        await NoteCacheService.setCommitments(newCommitments);
        const commitments = await NoteCacheService.getCommitments();

        setCommitments(commitments);
        setNullifierHashes(allNullifiers);
        const latestScannedBlock = await provider.getBlock("latest");
        localStorage.setItem(LOCAL_STORAGE_KEY, latestScannedBlock.block_number.toString());
        setLastScannedBlock(latestScannedBlock.block_number);
      } catch (err) {
        console.error("Error fetching events:", err);
        setError("Failed to fetch events");
      } finally {
        setIsLoading(false);
      }
    };

    fetchEvents();

    return;
  }, [provider, lastScannedBlock]);

  return { commitments, nullifierHashes, error, isLoading };
};
