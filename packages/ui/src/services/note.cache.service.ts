import Dexie from "dexie";
import { CommitmentEvent, Note } from "@/interfaces";

class NoteDatabase extends Dexie {
  notes: Dexie.Table<Note, number>;
  myNotes: Dexie.Table<Note, number>;
  commitments: Dexie.Table<CommitmentEvent, number>;
  merkleRoots: Dexie.Table<{ id: string; root: string }, string>;
  nullifierHashes: Dexie.Table<string, number>;

  constructor() {
    super("NoteDatabase");
    this.version(1).stores({
      myNotes: "++id, &commitment, encryptedOutput, index, value, bliding, nullifierHash",
      notes: "++id, &commitment, encryptedOutput, index, value, bliding, nullifierHash",
      commitments: "++id, &commitment, encryptedOutput, index",
      nullifierHashes: "++id, &hash",
      merkleRoots: "&id, root",
    });

    this.notes = this.table("notes");
    this.myNotes = this.table("myNotes");
    this.commitments = this.table("commitments");
    this.merkleRoots = this.table("merkleRoots");
    this.nullifierHashes = this.table("nullifierHashes");
  }
}

const db = new NoteDatabase();

class NoteCacheService {
  // My Notes
  static async getMyNotes(): Promise<Note[]> {
    return await db.myNotes.toArray();
  }

  static async setMyNotes(notes: Note[]): Promise<void> {
    const notesInDb = await db.myNotes.toArray();
    const newNotes = notes.filter(
      (note) => !notesInDb.some((dbNote) => dbNote.commitment === note.commitment)
    );
    await db.myNotes.bulkPut(newNotes);
  }

  static async clearMyNotes(): Promise<void> {
    await db.myNotes.clear();
  }

  // Notes
  static async getNotes(): Promise<Note[]> {
    return await db.notes.toArray();
  }

  static async setNotes(notes: Note[]): Promise<void> {
    const notesInDb = await db.notes.toArray();
    const newNotes = notes.filter(
      (note) => !notesInDb.some((dbNote) => dbNote.commitment === note.commitment)
    );
    await db.notes.bulkPut(newNotes);
  }

  static async clearNotes(): Promise<void> {
    await db.notes.clear();
  }

  // Commitments
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

  // Nullifier Hashes
  static async getNullifierHashes(): Promise<string[]> {
    return (await db.nullifierHashes.toArray());
  }

  static async setNullifierHashes(nullifiers: string[]): Promise<void> {
    const existingNullifiers = await db.nullifierHashes.toArray();
    const newNullifiers = nullifiers.filter(
      (nullifier) => !existingNullifiers.some((dbNullifier) => dbNullifier === nullifier)
    );
    await db.nullifierHashes.bulkPut(newNullifiers);
  }

  static async clearNullifierHashes(): Promise<void> {
    await db.nullifierHashes.clear();
  }
}

export default NoteCacheService;
