export interface NoteExpanded {
  receiver: string;
  value: number;
  commitment: string;
  nullifier: string;
  nullifierHash: string;
}

export interface Note {
  commitment: string;
  valueEncrypted: number;
  addressReceiver: string;
}


export interface CommitmentEvent {
  commitment: string;
  encryptedValue: {
    encryptedData: string;
    nonce: string;
  };
  address: string;
}

export interface ReceiverAccount {
  address: string;
  nullifier: string;
}