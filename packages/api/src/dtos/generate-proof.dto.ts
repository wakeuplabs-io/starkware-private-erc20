export interface GenerateProofDto {
  in_root : string,
  in_path : string[],
  in_direction_selector : boolean[],
  in_amount : string,
  in_commitment_nullifier : string,
  in_commitment_nullifier_hash : string,
  in_commitment_secret : string,
  out_receiver_account : string,
  out_root : string,
  out_amount_sender : string,
  out_amount_receiver : string,
  out_commitment_sender : string,
  out_commitment_receiver : string,
  out_subtree_root_path : string[]
  out_subtree_root_direction : boolean[]
}