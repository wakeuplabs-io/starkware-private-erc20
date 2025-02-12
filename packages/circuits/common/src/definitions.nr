use std::hash::poseidon2::Poseidon2::hash;

// account = hash(private_key) 
pub fn account(private_key: Field) -> Field {
    hash([private_key], 1)
}

// commitment = hash(owner, bliding, amount) // bliding = random number that makes commitment unique
pub fn commitment(owner: Field, value: Field, bliding: Field) -> Field {
    hash([owner, value, bliding], 3)
}

// commitment_tracker = hash(commitment, bliding) // same bliding as for commitment
pub fn commitment_tracker(commitment: Field, bliding: Field) -> Field {
    hash([commitment, bliding], 2)
}

// nullifier = hash(commitment, private_key, leaf_index)
pub fn nullifier(
    commitment: Field,
    private_key: Field,
    index: Field,
) -> Field {
    hash([commitment, private_key, index], 3)
}

// allowance_hash = hash(owner, spender, value)
pub fn allowance_hash(owner: Field, spender: Field, value: Field) -> Field {
    hash([owner, spender, value], 3)
}

// allowance_relationship = hash(owner, spender)
pub fn allowance_relationship(owner: Field, spender: Field) -> Field {
    hash([owner, spender], 2)
}
