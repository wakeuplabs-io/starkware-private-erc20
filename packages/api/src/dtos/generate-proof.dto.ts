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