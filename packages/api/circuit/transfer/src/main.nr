mod merkle_tree;
mod hash_checks;
use crate::merkle_tree::merkle_inclusion;
use crate::hash_checks::{generate_commitment, generate_commitment_with_account, nullifier_check};


global DEPTH: u32 = 4;

pub fn main(
    balance: Field,
    amount: Field,
    receiver_account: Field,
    change_account: Field,
    secret_sender_account: Field,
    nullifier: Field,
    nullifier_hash: Field,
    root: pub Field,
    path: [Field; DEPTH],
    direction_selector: [bool; DEPTH],
    out_commitment: [Field; 2],
    new_root: Field,
    new_path: [Field; DEPTH],
    new_direction_selector: [bool; DEPTH],
    new_path_change: [Field; DEPTH],
    new_direction_selector_change: [bool; DEPTH],
) {
  
    let commitment = generate_commitment(balance, nullifier, secret_sender_account);

    merkle_inclusion(root, path, direction_selector, commitment);

    nullifier_check(nullifier_hash, nullifier);

    let receiver_commitment = generate_commitment_with_account(amount, receiver_account);


    let sender_change_commitment = generate_commitment_with_account(balance - amount, change_account); 

    assert(receiver_commitment == out_commitment[0]);

    assert(sender_change_commitment == out_commitment[1]);

    merkle_inclusion(new_root, new_path, new_direction_selector, out_commitment[0]);
  
    merkle_inclusion(new_root, new_path_change, new_direction_selector_change, out_commitment[1]);
}


// #[test]
// fn test_scenario_ok() {
//     let amount = 200;
//     let balance = 300;
//     let nullifier = 123456;
//     let nullifier_hash = poseidon::bn254::hash_1([nullifier]);

//     let commitment = poseidon::bn254::hash_2([nullifier, balance.to_field()]);


//     let leafs: [Field; 4096] = [
//         commitment,
//         poseidon::bn254::hash_1([2]),
//         poseidon::bn254::hash_1([3]),
//         poseidon::bn254::hash_1([4]),
//     ];

//     let second_level_1 = poseidon::bn254::hash_2([leafs[0], leafs[1]]);
//     let second_level_2 = poseidon::bn254::hash_2([leafs[2], leafs[3]]);
//     let root = poseidon::bn254::hash_2([second_level_1, second_level_2]);
//     let path: [Field; DEPTH] = [
//         leafs[1], second_level_2,
//     ];
//     let direction_selector: [bool; DEPTH] = [
//         false, false
//     ];

//     main(
//       amount,
//       balance,
//       commitment,
//       root,
//       path,
//       direction_selector,
//       nullifier,
//       nullifier_hash,
//     );
// }
