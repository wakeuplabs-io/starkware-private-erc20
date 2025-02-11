import Dexie from "dexie";
import { CommitmentEvent, Note } from "@/interfaces";

class NoteDatabase extends Dexie {
  notes: Dexie.Table<Note, number>;
  commitments: Dexie.Table<CommitmentEvent, number>;
  merkleRoots: Dexie.Table<{ id: string; root: string }, string>;

  constructor() {
    super("NoteDatabase");
    this.version(1).stores({
      notes: "++id, &commitment, encryptedOutput, index, value, bliding",
      commitments: "++id, &commitment, encryptedOutput, index",
      merkleRoots: "&id, root",
    });

    this.notes = this.table("notes");
    this.commitments = this.table("commitments");
    this.merkleRoots = this.table("merkleRoots");
  }
}

const db = new NoteDatabase();

class NoteCacheService {
  // Notes
  static async getMyNotes(): Promise<Note[]> {
    return await db.notes.toArray();
  }

  static async setMyNotes(notes: Note[]): Promise<void> {
    const notesInDb = await db.notes.toArray();
    const newNotes = notes.filter(
      (note) => !notesInDb.some((dbNote) => dbNote.commitment === note.commitment)
    );
    await db.notes.bulkPut(newNotes);
  }

  static async clearMyNotes(): Promise<void> {
    await db.notes.clear();
  }

  // Commitments Count
  static async getCommitments(): Promise<CommitmentEvent[]> {
    return await db.commitments.toArray();
  }

  static async setCommitments(commitments: CommitmentEvent[]): Promise<void> {
    const commitmentsInDb = await db.commitments.toArray();
    const newCommitments = commitments.filter(
      (commitment) => !commitmentsInDb.some((dbCommitment) => dbCommitment.commitment === commitment.commitment)
    );
    await db.commitments.bulkPut(newCommitments);
  }

  static async clearCommitments(): Promise<void> {
    await db.commitments.clear();
  }

  // Merkle Root
  static async getMerkleRoot(): Promise<string | null> {
    const entry = await db.merkleRoots.get("merkleRoot");
    return entry ? entry.root : null;
  }

  static async setMerkleRoot(rootHash: string): Promise<void> {
    await db.merkleRoots.put({ id: "merkleRoot", root: rootHash });
  }

  static async clearMerkleRoot(): Promise<void> {
    await db.merkleRoots.delete("merkleRoot");
  }
}

export default NoteCacheService;
