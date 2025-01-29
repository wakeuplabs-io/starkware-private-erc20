export interface Note {
  receiver: string;
  value: number;
}

export interface CommitmentEvent {
  commitment: string;
  encryptedValue: {
    encryptedData: string;
    nonce: string;
  };
  address: string;
}