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
  root: string;
  path: string[];
  direction_selector: boolean[];
  new_root: string;
  new_path: string[];
  new_direction_selector: boolean[];
  in_amount: number;
  in_commitment_nullifier: string;
  in_commitment_nullifier_hash: string;
  in_commitment_secret: string;
  out_amount_sender: number;
  out_amount_receiver: number;
  receiver_account: string;
  out_commitments: string[];
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