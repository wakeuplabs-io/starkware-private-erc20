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

export interface TransferProofDto {
  owner_private_key: string;
  receiver_account: string;
  in_commitment_root: string;
  in_commitment_path: string[];
  in_commitment_direction_selector: boolean[];
  in_commitment_value: string;
  in_commitment_bliding: string;
  in_commitment_spending_tracker: string;
  out_receiver_value: string;
  out_receiver_bliding: string;
  out_receiver_commitment: string;
  out_sender_value: string;
  out_sender_bliding: string;
  out_sender_commitment: string;
  out_root: string;
  out_subtree_root_path: string[];
  out_subtree_root_direction: boolean[];
}

export interface ApproveProofDto {
  in_private_key: string;
  in_amount: string;
  in_spender: string;
  out_allowance_hash: string;
  out_relationship_id: string;
}

export interface TransferFromProofDto {
  owner_account: string;
  receiver_account: string;
  spender_private_key: string;
  in_commitment_root: string;
  in_commitment_path: string[];
  in_commitment_direction_selector: boolean[];
  in_commitment_bliding: string;
  in_commitment_value: string;
  in_commitment_spending_tracker: string;
  in_allowance_value: string;
  in_allowance_hash: string;
  in_allowance_relationship: string;
  out_allowance_hash: string;
  out_receiver_value: string;
  out_receiver_bliding: string;
  out_receiver_commitment: string;
  out_owner_value: string;
  out_owner_bliding: string;
  out_owner_commitment: string;
  out_root: string;
  out_subtree_root_path: string[];
  out_subtree_direction_selector: boolean[];
}