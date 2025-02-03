export interface GenerateProofDto {
  amount: number;
  balance: number;
  receiver_address: string;
  commitment: string;
  direction_selector: boolean[];
  nullifier: string;
  nullifier_hash: string;
  path: string[];
  root: string;
}