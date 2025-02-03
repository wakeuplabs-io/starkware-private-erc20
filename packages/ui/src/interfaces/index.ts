export interface NoteExpanded {
  receiver: string;
  value: number;
  encryptedValue: string;
  commitment: string;
  nullifier: string;
  nullifierHash: string;
}

export interface Note {
  commitment: string;
  valueEncrypted: number;
  addressReceiver: string;
}


export interface CommitmentEvent {
  commitment: string;
  encryptedValue: string;
  address: string;
}

export interface ReceiverAccount {
  address: string;
  nullifier: string;
}

export interface GenerateProofDto {
  amount: number;
  balance: number;
  receiver_address: string;
  commitment: string;
  direction_selector: boolean[];
  nullifier: string;
  nullifier_hash: string;
  path: string[];
  root: string;
}