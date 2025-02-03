import { useEffect, useState } from "react";
import { useNetwork, useAccount, useProvider } from "@starknet-react/core";
import { selector } from "starknet";
import { CommitmentEvent } from "@/interfaces";

const PRIVATE_ERC20_CONTRACT_ADDRESS =
  "0x000029f4430cc63c28456d6c5b54029d00338e4c4ec7c873aa1dc1bc3fb38d55";

export const useEvents = () => {
  const { chain } = useNetwork();
  const { address } = useAccount();
  const [events, setEvents] = useState<CommitmentEvent[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const { provider } = useProvider();
  const newNoteHash = selector.getSelectorFromName("NewNote");
  useEffect(() => {
    if (!chain || !address) return;

    setIsLoading(true);

    const fetchEvents = async () => {
      try {
        
        const events = await provider.channel.getEvents({
          address: PRIVATE_ERC20_CONTRACT_ADDRESS,
          keys: [[newNoteHash.toString()]],
          from_block: { block_number: 490000 },
          to_block: "latest",
          chunk_size: 100, 
        });
        console.log("events", events);
        const eventsData = events.events.map(event => event.data).filter(event => event[0].length > 5);
        const eventsDataParsed : CommitmentEvent[] = eventsData.map(event => {
          return {
            commitment: event[0],
            encryptedValue: event[1],
            address: event[2]
          };
        });
        setEvents(eventsDataParsed);
      } catch (err) {
        console.error("Error fetching events:", err);
        setError("Failed to fetch events");
      } finally {
        setIsLoading(false);
      }
    };

    fetchEvents();
  }, [chain, address, newNoteHash, provider]);

  return { events, error, isLoading };
};
