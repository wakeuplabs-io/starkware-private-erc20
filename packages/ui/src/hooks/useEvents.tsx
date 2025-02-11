import { useEffect, useState } from "react";
import { selector, events as Events, CallData } from "starknet";
import { useProvider } from "@starknet-react/core";
import { CommitmentEvent } from "@/interfaces";
import { PRIVATE_ERC20_CONTRACT_ADDRESS } from "@/constants";
import privateTokenAbi from "@/abi/private-erc20.abi";

const abiEvents = Events.getAbiEvents(privateTokenAbi);
const abiStructs = CallData.getAbiStruct(privateTokenAbi);
const abiEnums = CallData.getAbiEnum(privateTokenAbi);

export const useEvents = () => {
  const [commitments, setCommitments] = useState<CommitmentEvent[]>([]);
  const [nullifierHashes, setNullifierHashes] = useState<string[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const { provider } = useProvider();
  const newCommitmentHash = selector.getSelectorFromName("NewCommitment");
  const newNullifierHash = selector.getSelectorFromName("NewNullifier");

  useEffect(() => {
    setIsLoading(true);

    const fetchEvents = async () => {
      try {
        const eventsResponse = await provider.channel.getEvents({
          address: PRIVATE_ERC20_CONTRACT_ADDRESS,
          keys: [[newCommitmentHash, newNullifierHash]],
          from_block: { block_number: 500000 },
          to_block: "latest",
          chunk_size: 100,
        });
        const eventsParsed = Events.parseEvents(
          eventsResponse.events,
          abiEvents,
          abiStructs,
          abiEnums
        );
        const commitmentsParsed: CommitmentEvent[] = eventsParsed
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

        const nullifiersParsed: string[] = eventsParsed
          .filter(
            (event) =>
              event["contracts::privado::privado::Privado::NewNullifier"]
          )
          .map(
            (event) =>
              event[
                "contracts::privado::privado::Privado::NewNullifier"
              ]?.nullifier_hash?.toString() || ""
          );
        setCommitments(commitmentsParsed);
        setNullifierHashes(nullifiersParsed);
      } catch (err) {
        console.error("Error fetching events:", err);
        setError("Failed to fetch events");
      } finally {
        setIsLoading(false);
      }
    };

    fetchEvents();
  }, [newCommitmentHash, newNullifierHash, provider]);


  return { commitments, nullifierHashes, error, isLoading };
};
