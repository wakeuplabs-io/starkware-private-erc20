export interface Account {
  // proof ownership of commitments
  owner: {
    address: bigint; // this is our sharable address
    privateKey: bigint;
    publicKey: bigint;
  },
  // decrypts commitments data
  viewer: {
    privateKey: bigint; // we optionally share this with third party
    publicKey: bigint; // this is our sharable public key
  }
}

export interface Note {
  index: bigint;
  commitment: bigint;
  encryptedOutput: string;
  bliding?: bigint;
  value?: bigint;
  spent?: boolean;
  nullifier?: bigint;
}

export interface CommitmentEvent {
  commitment: bigint;
  encryptedOutput: string;
  index: bigint;
}

export interface ApprovalEvent {
  allowance_hash: bigint;
  allowance_relationship: bigint;
  output_enc_owner: string;
  output_enc_spender: string;
  timestamp: bigint;
}

export interface CommitmentPayload {
  value: bigint;
  bliding: bigint;
}

export interface ApprovalPayload {
  allowance: bigint;
  view: {
    publicKey: bigint;
    privateKey: bigint;
  },
  commitments: {
    commitment: bigint;
    value: bigint;
    bliding: bigint;
  }[];
}

export interface ReceiverAccount {
  address: string;
  nullifier: string;
}

export interface TransferProofDto {
  // accounts details
  sender_private_key: string;
  receiver_account: string;
  // utxo inputs
  in_commitment_root: string;
  in_commitment_path: string[];
  in_commitment_direction_selector: boolean[];
  in_commitment_value: string;
  in_commitment_bliding: string;
  in_commitment_nullifier: string;
  // utxo outputs
  out_receiver_commitment_value: string;
  out_receiver_commitment_bliding: string;
  out_receiver_commitment: string;
  out_sender_commitment_value: string;
  out_sender_commitment_bliding: string;
  out_sender_commitment: string;
  // updated root
  out_root: string;
  out_subtree_root_path: string[]; // path of hash(out_sender_commitment, out_receiver_commitment)
  out_subtree_root_direction_selector: boolean[]; // path direct
}

export interface ApproveProofDto {
  in_private_key: string;
  in_amount: string;
  in_spender: string;
  out_allowance_hash: string;
  out_relationship_id: string;
}

export interface TransferFromProofDto {
  // account details
  owner_account: string;
  receiver_account: string;
  spender_private_key: string;
  // input commitment details
  in_commitment_root: string;
  in_commitment_path: string[];
  in_commitment_direction_selector: boolean[];
  in_commitment_bliding: string;
  in_commitment_value: string;
  in_commitment_nullifier: string;
  // allowance utxo details
  in_allowance_value: string;
  in_allowance_hash: string;
  in_allowance_relationship: string;
  out_allowance_hash: string;
  // out receiver commitment detailsa
  out_receiver_value: string;
  out_receiver_bliding: string;
  out_receiver_commitment: string;
  // out owner commitment details
  out_owner_value: string;
  out_owner_bliding: string;
  out_owner_commitment: string;
  // output commitment details
  out_root: string;
  out_subtree_root_path: string[];
  out_subtree_direction_selector: boolean[];
}

export interface DepositProofDto {
  // accounts details
  receiver_account: string;
  // utxo inputs
  in_commitment_root: string;
  in_public_amount: string;
  // utxo outputs
  out_receiver_commitment_bliding: string;
  out_receiver_commitment: string;
  // updated root
  out_root: string;
  out_subtree_root_path: string[];
  out_subtree_root_direction_selector: boolean[];
}
