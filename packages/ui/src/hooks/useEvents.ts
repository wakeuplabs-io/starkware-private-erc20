import { useEffect, useState } from "react";
import { useNetwork, useAccount, useProvider } from "@starknet-react/core";
import { selector } from "starknet";
import { CommitmentEvent } from "@/interfaces";
import { CipherService } from "@/services/cipher.service";
import naclUtil from "tweetnacl-util";

import { BarretenbergService } from "@/services/bb.service";


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
        const savedPublicKey = localStorage.getItem("PublicKey");
        const savedSecretKey = localStorage.getItem("SecretKey");
        const events = await provider.channel.getEvents({
          address: PRIVATE_ERC20_CONTRACT_ADDRESS,
          keys: [[newNoteHash.toString()]],
          from_block: { block_number: 490000 },
          to_block: "latest",
          chunk_size: 100, 
        });
        console.log("events", events);
        const eventsData = events.events.map(event => event.data).filter(event => event[0].length > 5);
        let eventsDataParsed : CommitmentEvent[] = eventsData.map(event => {
          return {
            commitment: event[0],
            encryptedValue: event[1],
            address: event[2]
          };
        });
        if (savedPublicKey && savedSecretKey) {
          eventsDataParsed = [
            {

              commitment: BarretenbergService.generateCommitment("0x246956d284ee9a05672f5ca4067d005a37768de580e0737246dcbbf9e79c390f", 100),
              encryptedValue: CipherService.encryptNote(
                { value: 100 },
                naclUtil.decodeBase64(savedPublicKey),
                naclUtil.decodeBase64(savedSecretKey)
              ),

              address: "0x246956d284ee9a05672f5ca4067d005a37768de580e0737246dcbbf9e79c390f",
            },
            {
              commitment: BarretenbergService.generateCommitment("0x2a165b3b4bffeed9041aac3e528c2741021863f50f096c25f15c3c60272074ee", 650),
              encryptedValue: CipherService.encryptNote(
                { value: 650 },
                naclUtil.decodeBase64(savedPublicKey),
                naclUtil.decodeBase64(savedSecretKey)
              ),
              address: "0x2a165b3b4bffeed9041aac3e528c2741021863f50f096c25f15c3c60272074ee",
            },
            {
              commitment: BarretenbergService.generateCommitment("0x09ee9b0a2e8a3fe6677891a7886921b6baa0dc642bd985333f8735e8d9020366", 500 ),
              encryptedValue: CipherService.encryptNote(
                { value: 500 },
                naclUtil.decodeBase64(savedPublicKey),
                naclUtil.decodeBase64(savedSecretKey)
              ),

              address: "0x09ee9b0a2e8a3fe6677891a7886921b6baa0dc642bd985333f8735e8d9020366",
            },
          ];
        }

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
