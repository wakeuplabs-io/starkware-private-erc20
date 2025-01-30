mod merkle_tree;
mod hash_checks;
use crate::merkle_tree::merkle_inclusion;
use crate::hash_checks::{nullifier_check, sender_commitment_check};

use std::hash::poseidon;
global DEPTH: u32 = 2;

trait Fieldable {
    fn to_field(self) -> Field;
}

impl Fieldable for u32 {
    fn to_field(self) -> Field {
        self as Field
    }
}


pub fn main(
    amount: u32,
    balance: u32,
    commitment: Field,
    root: Field,
    path: [Field; DEPTH],
    direction_selector: [bool; DEPTH],
    nullifier: Field,
    nullifier_hash: Field,
) {
    // 1. The commitment is in the merkle tree
    merkle_inclusion(root, commitment, path, direction_selector);

    // 2. The sender knows the nullifier
    nullifier_check(nullifier_hash, nullifier);

    // 3. The sender can create the commitment
    sender_commitment_check(commitment, nullifier, balance);

    // 4. The sender has enough balance to send the amount
    assert(balance >= amount);

    // receiver_nonce_address ya es el commitment

    // let calculated_new_receiver = poseidon::bn254::hash_2([receiver_nonce_address, Field(amount)]);
    // assert(calculated_new_receiver == new_commitment_receiver);

    //TODO: De momento solo enviar nota completa
    // if balance > amount {
    //     let calculated_new_change = hash([change_addr, secret_change, balance - amount]);
    //     assert(calculated_new_change == new_commitment_change);
    // }
}

#[test]
fn test_scenario_ok() {
    let secret = 1234;
    let balance = 300;
    let amount = 200;
    let nullifier = 123456;
    let nullifier_hash = poseidon::bn254::hash_1([nullifier]);

    let commitment = poseidon::bn254::hash_3([nullifier, secret, balance.to_field()]);


    let leafs: [Field; 4] = [
        commitment,
        poseidon::bn254::hash_1([2]),
        poseidon::bn254::hash_1([3]),
        poseidon::bn254::hash_1([4]),
    ];

    let second_level_1 = poseidon::bn254::hash_2([leafs[0], leafs[1]]);
    let second_level_2 = poseidon::bn254::hash_2([leafs[2], leafs[3]]);
    let root = poseidon::bn254::hash_2([second_level_1, second_level_2]);
    let path: [Field; DEPTH] = [
        leafs[1], second_level_2,
    ];
    let direction_selector: [bool; DEPTH] = [
        false, false
    ];

    main(
      secret,
      amount,
      balance,
      commitment,
      root,
      path,
      direction_selector,
      nullifier,
      nullifier_hash,
    );
}
