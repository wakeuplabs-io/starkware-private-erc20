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
  direction_selector: boolean[];
  nullifier: string;
  nullifier_hash: string;
  path: string[];
  root: string;
  receiver_account: string;
  change_account: string;
  secret_sender_account: string;
  out_commitment: string[];
  new_root: string;
  new_path: string[];
  new_direction_selector: boolean[];
  new_path_change: string[];
  new_direction_selector_change: boolean[];
}

export interface SimulateAddCommitmentsResult {
  newRoot: string;
  proofs: { commitment: string; path: string[]; directionSelector: boolean[] }[];
}

export interface SimulatedPath {
  commitment: string;
  path: string[];
  directionSelector: boolean[]
  address: string;
}