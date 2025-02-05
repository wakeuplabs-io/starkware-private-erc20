export interface Note {
  commitment: bigint;
  bliding?: bigint;
  encryptedOutput: string;
  value?: bigint;
  nullifier?: bigint;
  index: bigint;
}

export interface CommitmentEvent {
  commitment: bigint;
  encryptedOutput: string;
  index: bigint;
}

export interface DecryptedOutput {
  value: bigint;    
  bliding: bigint;
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
