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
