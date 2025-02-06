export interface Note {
  commitment: bigint;
  bliding?: bigint;
  encryptedOutput: string;
  value?: bigint;
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
  in_amount: string;
  in_bliding: string;
  in_commitment_nullifier_hash: string;
  in_direction_selector: boolean[];
  in_path: string[];
  in_private_key: string;
  in_root: string;
  out_receiver_account: string;
  out_receiver_amount: string;
  out_receiver_bliding: string;
  out_receiver_commitment: string;
  out_root: string;
  out_sender_amount: string;
  out_sender_bliding: string;
  out_sender_commitment: string;
  out_subtree_root_path: string[];
  out_subtree_root_direction: boolean[];
}
