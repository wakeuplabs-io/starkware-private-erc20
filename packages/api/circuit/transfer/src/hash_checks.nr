use std::hash::poseidon2;


pub fn generate_commitment( value: Field, nullifier: Field, secret_account: Field ) -> Field {
    let receiver_account = poseidon2::Poseidon2::hash([secret_account, nullifier], 2);
    let hash = poseidon2::Poseidon2::hash([receiver_account, value], 2);
    hash
}

pub fn generate_commitment_with_account( value: Field, receiver_account: Field ) -> Field {
    poseidon2::Poseidon2::hash([receiver_account, value], 2)
}

pub fn nullifier_check(
    nullifier_hash: Field,
    nullifier: Field
) {
    let calculated_hash = poseidon2::Poseidon2::hash([nullifier], 1);
    assert(calculated_hash == nullifier_hash);
}

pub fn sender_commitment_check(
    sender_commitment: Field,
    receiver_address: Field,
    balance: Field
) {
    let calculated_commitment = poseidon2::Poseidon2::hash([receiver_address, balance],2);
    assert(calculated_commitment == sender_commitment);
}

#[test]
fn test_nullifier_check() {
    let nullifier = 123456;
    let calculated_hash = poseidon2::Poseidon2::hash([nullifier], 1);
    
    nullifier_check(calculated_hash, nullifier);
}