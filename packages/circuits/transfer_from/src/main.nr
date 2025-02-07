mod merkle_tree;
use crate::merkle_tree::assert_merkle_inclusion;
use std::hash::poseidon2::Poseidon2::hash;

// TODO: update before deploying. So far haven't found way to override for testing
global DEPTH: u32 = 2;

// address = hash(private_key)
// commitment = hash(address, bliding, amount)
// nullifier = hash(commitment, private_key, path)

pub fn main(
    // utxo inputs
    in_root: pub Field,
    in_path: [Field; DEPTH],
    in_direction_selector: [bool; DEPTH],
    in_amount: Field,
    in_commitment_nullifier_hash: pub Field,
    in_private_key: Field,
    in_bliding: Field,
    // utxo outputs
    out_receiver_account: Field,
    out_receiver_amount: Field,
    out_receiver_bliding: Field,
    out_receiver_commitment: pub Field,
    out_sender_amount: Field,
    out_sender_bliding: Field,
    out_sender_commitment: pub Field,
    out_root: pub Field,
    out_subtree_root_path: [Field; DEPTH - 1], // path of hash(out_sender_commitment, out_receiver_commitment)
    out_subtree_root_direction: [bool; DEPTH - 1], // path direction of hash(out_sender_commitment, out_receiver_commitment)
) {
    // check in_commitment is included in the root and belongs to sender
    let sender_account = generate_account(in_private_key);
    let in_commitment = generate_commitment(sender_account, in_amount, in_bliding);
    assert_merkle_inclusion(in_root, in_path, in_direction_selector, in_commitment);

    // check nullifier_hash belongs to nullifier, tied with previous check nullifier derives in commitment
    let nullifier = generate_nullifier(in_commitment, in_private_key, in_path);
    assert(hash([nullifier], 1) == in_commitment_nullifier_hash);

    // check utxo
    assert(in_amount == out_receiver_amount + out_sender_amount, "Invalid UTXO amounts");

    // validate commitment amounts and receivers are correct
    assert(generate_commitment(sender_account, out_sender_amount, out_sender_bliding) == out_sender_commitment);
    assert(generate_commitment(out_receiver_account,out_receiver_amount, out_receiver_bliding) == out_receiver_commitment);

    // check we're inserting in a previously empty subtree
    let zero_subtree_root = hash([0, 0], 2);
    assert_merkle_inclusion(
        in_root,
        out_subtree_root_path,
        out_subtree_root_direction,
        zero_subtree_root,
    );

    // check newly inserted commitments belong to new_root
    let new_subtree_root = hash([out_sender_commitment, out_receiver_commitment], 2);
    assert_merkle_inclusion(
        out_root,
        out_subtree_root_path,
        out_subtree_root_direction,
        new_subtree_root,
    );
}

pub fn allowance_hash_builder(address: Field, spender: Field, amount: Field) -> Field {
    hash([address, spender, amount], 3)
}

pub fn generate_commitment(account: Field, value: Field, bliding: Field) -> Field {
    hash([account, value, bliding], 3)
}

pub fn generate_nullifier(
    commitment: Field,
    private_key: Field,
    commitment_path: [Field; DEPTH],
) -> Field {
    let mut params: [Field; DEPTH + 2] = [0; DEPTH + 2];
    params[0] = commitment;
    params[1] = private_key;

    for i in 0..DEPTH {
        params[i + 2] = commitment_path[i];
    }

    hash(params, DEPTH + 2)
}

pub fn generate_account(private_key: Field) -> Field {
    hash([private_key], 1)
}

#[test]
fn test_allowed_transfer() {
    // generate amounts
    let in_amount = 10;
    let out_receiver_amount = 2;
    let out_sender_amount = 8;

    // account details
    let in_private_key = 1;
    let sender_account = generate_account(in_private_key);

    // generate commitment
    let in_bliding = 2;
    let in_commitment = generate_commitment(sender_account, in_amount, in_bliding);

    // output commitment generation
    let receiver_account = generate_account(100);
    let out_sender_bliding = 3;
    let out_receiver_bliding = 3;
    let out_receiver_commitment = generate_commitment(receiver_account, out_receiver_amount, out_receiver_bliding);
    let out_sender_commitment = generate_commitment(sender_account, out_sender_amount, out_sender_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let old_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
    let new_root = hash([new_first_level_l, new_first_level_r], 2);

    // nullifier
    let in_commitment_path = [ 1, old_first_level_r ];
    let in_commitment_direction = [false, false];
    let in_commitment_nullifier = generate_nullifier(in_commitment, in_private_key, in_commitment_path);
    let in_commitment_nullifier_hash = hash([in_commitment_nullifier], 1);

    main(
        old_root,
        in_commitment_path,
        in_commitment_direction,
        in_amount,
        in_commitment_nullifier_hash,
        in_private_key,
        in_bliding,
        receiver_account,
        out_receiver_amount,
        out_receiver_bliding,
        out_receiver_commitment,
        out_sender_amount,
        out_sender_bliding,
        out_sender_commitment,
        new_root,
        [new_first_level_l],
        [true]
    );
}

#[test(should_fail_with = "Invalid UTXO amounts")]
fn test_invalid_utxo_amounts() {
    // generate amounts
    let in_amount = 10;
    let out_receiver_amount = 2;
    let out_sender_amount = 8000; // // <-------------------------------------------- out more than it should

    // account details
    let in_private_key = 1;
    let sender_account = generate_account(in_private_key);

    // generate commitment
    let in_bliding = 2;
    let in_commitment = generate_commitment(sender_account, in_amount, in_bliding);

    // output commitment generation
    let receiver_account = generate_account(100);
    let out_sender_bliding = 3;
    let out_receiver_bliding = 3;
    let out_receiver_commitment = generate_commitment(receiver_account, out_receiver_amount, out_receiver_bliding);
    let out_sender_commitment = generate_commitment(sender_account, out_sender_amount, out_sender_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let old_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
    let new_root = hash([new_first_level_l, new_first_level_r], 2);

    // nullifier
    let in_commitment_path = [ 1, old_first_level_r ];
    let in_commitment_direction = [false, false];
    let in_commitment_nullifier = generate_nullifier(in_commitment, in_private_key, in_commitment_path);
    let in_commitment_nullifier_hash = hash([in_commitment_nullifier], 1);

    main(
        old_root,
        in_commitment_path,
        in_commitment_direction,
        in_amount,
        in_commitment_nullifier_hash,
        in_private_key,
        in_bliding,
        receiver_account,
        out_receiver_amount,
        out_receiver_bliding,
        out_receiver_commitment,
        out_sender_amount,
        out_sender_bliding,
        out_sender_commitment,
        new_root,
        [new_first_level_l],
        [true]
    );
}

#[test(should_fail)]
fn test_unlinked_root() {
    // generate amounts
    let in_amount = 10;
    let out_receiver_amount = 2;
    let out_sender_amount = 8000; // Notice here

    // account details
    let in_private_key = 1;
    let sender_account = generate_account(in_private_key);

    // generate commitment
    let in_bliding = 2;
    let in_commitment = generate_commitment(sender_account, in_amount, in_bliding);

    // output commitment generation
    let receiver_account = generate_account(100);
    let out_sender_bliding = 3;
    let out_receiver_bliding = 3;
    let out_receiver_commitment = generate_commitment(receiver_account, out_receiver_amount, out_receiver_bliding);
    let out_sender_commitment = generate_commitment(sender_account, out_sender_amount, out_sender_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let old_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([100000, 1], 2); // <-------------------------------------------- Removed in commitment
    let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
    let new_root = hash([new_first_level_l, new_first_level_r], 2);

    // nullifier
    let in_commitment_path = [ 1, old_first_level_r ];
    let in_commitment_direction = [false, false];
    let in_commitment_nullifier = generate_nullifier(in_commitment, in_private_key, in_commitment_path);
    let in_commitment_nullifier_hash = hash([in_commitment_nullifier], 1);

    main(
        old_root,
        in_commitment_path,
        in_commitment_direction,
        in_amount,
        in_commitment_nullifier_hash,
        in_private_key,
        in_bliding,
        receiver_account,
        out_receiver_amount,
        out_receiver_bliding,
        out_receiver_commitment,
        out_sender_amount,
        out_sender_bliding,
        out_sender_commitment,
        new_root,
        [new_first_level_l],
        [true]
    );
}
#[test(should_fail)]
fn test_missing_new_commits() {
    // generate amounts
    let in_amount = 10;
    let out_receiver_amount = 2;
    let out_sender_amount = 8000; // Notice here

    // account details
    let in_private_key = 1;
    let sender_account = generate_account(in_private_key);

    // generate commitment
    let in_bliding = 2;
    let in_commitment = generate_commitment(sender_account, in_amount, in_bliding);

    // output commitment generation
    let receiver_account = generate_account(100);
    let out_sender_bliding = 3;
    let out_receiver_bliding = 3;
    let out_receiver_commitment = generate_commitment(receiver_account, out_receiver_amount, out_receiver_bliding);
    let out_sender_commitment = generate_commitment(sender_account, out_sender_amount, out_sender_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let old_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([0, 0], 2);  // <-------------------------------------------- Missing new commitments
    let new_root = hash([new_first_level_l, new_first_level_r], 2);

    // nullifier
    let in_commitment_path = [ 1, old_first_level_r ];
    let in_commitment_direction = [false, false];
    let in_commitment_nullifier = generate_nullifier(in_commitment, in_private_key, in_commitment_path);
    let in_commitment_nullifier_hash = hash([in_commitment_nullifier], 1);

    main(
        old_root,
        in_commitment_path,
        in_commitment_direction,
        in_amount,
        in_commitment_nullifier_hash,
        in_private_key,
        in_bliding,
        receiver_account,
        out_receiver_amount,
        out_receiver_bliding,
        out_receiver_commitment,
        out_sender_amount,
        out_sender_bliding,
        out_sender_commitment,
        new_root,
        [new_first_level_l],
        [true]
    );
}
