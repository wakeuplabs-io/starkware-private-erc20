export interface Note {
  index: bigint;
  commitment: bigint;
  encryptedOutput: string;
  bliding?: bigint;
  value?: bigint;
  spent?: boolean;
  nullifierHash?: bigint;
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
  // accounts details
  sender_private_key: string,
  receiver_account: string,
  // utxo inputs
  in_commitment_root: string,
  in_commitment_path: string[],
  in_commitment_direction_selector: boolean[],
  in_commitment_value: string,
  in_commitment_bliding: string,
  in_commitment_nullifier_hash: string,
  // utxo outputs
  out_receiver_commitment_value: string,
  out_receiver_commitment_bliding: string,
  out_receiver_commitment: string,
  out_sender_commitment_value: string,
  out_sender_commitment_bliding: string,
  out_sender_commitment: string,
  // updated root
  out_root: string,
  out_subtree_root_path: string[],
  out_subtree_root_direction_selector: boolean[],
}

