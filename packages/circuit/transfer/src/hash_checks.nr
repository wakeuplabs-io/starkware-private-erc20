use std::hash::poseidon;

pub fn nullifier_check(
    nullifier_hash: Field,
    nullifier: Field
) {
    let calculated_hash = poseidon::bn254::hash_1([nullifier]);
    assert(calculated_hash == nullifier_hash);
}

pub fn sender_commitment_check(
    sender_commitment: Field,
    nullifier: Field,
    secret: Field,
    balance: u32
) {
    let calculated_commitment = poseidon::bn254::hash_3([nullifier, secret, balance.to_field()]);
    assert(calculated_commitment == sender_commitment);
}


#[test]
fn test_nullifier_check() {
    let nullifier = 123456;
    let calculated_hash = poseidon::bn254::hash_1([nullifier]);
    
    nullifier_check(calculated_hash, nullifier);
}