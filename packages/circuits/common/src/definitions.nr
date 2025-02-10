use std::hash::poseidon2::Poseidon2::hash;

pub fn account(private_key: Field) -> Field {
    hash([private_key], 1)
}

pub fn commitment(account: Field, value: Field, bliding: Field) -> Field {
    hash([account, value, bliding], 3)
}

pub fn commitment_tracker(commitment: Field, bliding: Field) -> Field {
    hash([commitment, bliding], 3)
}

pub fn nullifier(
    commitment: Field,
    private_key: Field,
    index: Field,
) -> Field {
    hash([commitment, private_key, index], 3)
}

pub fn allowance_hash(address: Field, spender: Field, amount: Field) -> Field {
    hash([address, spender, amount], 3)
}

pub fn allowance_relationship(owner: Field, spender: Field) -> Field {
    hash([owner, spender], 2)
}
