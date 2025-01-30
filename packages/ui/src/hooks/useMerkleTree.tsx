import { useEffect, useState } from "react";
import { MerkleTree } from "@/utils/merkle-tree"; // Asegúrate de importar el MerkleTree correctamente
import { CommitmentEvent } from "@/interfaces";

export const useMerkleTree = (events: CommitmentEvent[]) => {
  const [merkleTree, setMerkleTree] = useState<MerkleTree | null>(null);
  const [root, setRoot] = useState<string>("");

  useEffect(() => {
    if (!events.length) return;

    const initializeMerkleTree = async () => {
      const tree = new MerkleTree();
      for (const event of events) {
        await tree.addCommitment(event.commitment);
      }
      setMerkleTree(tree);
      setRoot(tree.getRoot());
    };

    initializeMerkleTree();
  }, [events]);

  return { merkleTree, root };
};
