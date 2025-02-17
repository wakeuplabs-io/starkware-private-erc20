use common::definitions::{account, commitment, nullifier};
use common::merkle_tree::{assert_merkle_inclusion};
use std::hash::poseidon2::Poseidon2::hash;

// TODO: update before deploying. So far haven't found way to override for testing
global DEPTH: u32 = 2;

pub fn main(
    // accounts details
    sender_private_key: Field,
    receiver_account: Field,
    // utxo inputs
    in_commitment_root: pub Field,
    in_commitment_path: [Field; DEPTH],
    in_commitment_direction_selector: [bool; DEPTH],
    in_commitment_value: Field,
    in_commitment_bliding: Field,
    in_commitment_nullifier: pub Field,
    // utxo outputs
    out_receiver_commitment_value: Field,
    out_receiver_commitment_bliding: Field,
    out_receiver_commitment: pub Field,
    out_sender_commitment_value: Field,
    out_sender_commitment_bliding: Field,
    out_sender_commitment: pub Field,
    // updated root
    out_root: pub Field,
    out_subtree_root_path: [Field; DEPTH - 1], // path of hash(out_sender_commitment, out_receiver_commitment)
    out_subtree_root_direction_selector: [bool; DEPTH - 1], // path direction of hash(out_sender_commitment, out_receiver_commitment)
) {
    // check in_commitment is included in the root and belongs to sender
    let sender_account = account(sender_private_key);
    let in_commitment = commitment(sender_account, in_commitment_value, in_commitment_bliding);
    assert_merkle_inclusion(
        in_commitment_root,
        in_commitment_path,
        in_commitment_direction_selector,
        in_commitment,
        "Input commitment doesn't belong to tree",
    );
    assert_eq(in_commitment_nullifier, nullifier(in_commitment, in_commitment_bliding), "Invalid commitment nullifier");

    // check utxo
    assert_eq(
        in_commitment_value,
        out_receiver_commitment_value + out_sender_commitment_value,
        "Invalid UTXO amounts",
    );

    // validate commitment amounts and receivers are correct
    assert_eq(
        commitment(sender_account, out_sender_commitment_value, out_sender_commitment_bliding),
        out_sender_commitment,
          "Invalid out sender commitment",
    );
    assert_eq(
        commitment(receiver_account, out_receiver_commitment_value, out_receiver_commitment_bliding),
        out_receiver_commitment,
            "Invalid out receiver commitment",
    );

    // check we're inserting in a previously empty subtree
    let zero_subtree_root = hash([0, 0], 2);
    assert_merkle_inclusion(
        in_commitment_root,
        out_subtree_root_path,
        out_subtree_root_direction_selector,
        zero_subtree_root,
        "Missing commitments from old tree in new tree",
    );

    // check newly inserted commitments belong to out_root
    let new_subtree_root = hash([out_sender_commitment, out_receiver_commitment], 2);
    assert_merkle_inclusion(
        out_root,
        out_subtree_root_path,
        out_subtree_root_direction_selector,
        new_subtree_root,
        "New commits not included in new root",
    );
}

#[test]
fn test_allowed_transfer() {
    // generate amounts
    let in_commitment_value = 10;
    let out_receiver_commitment_value = 2;
    let out_sender_commitment_value = 8;

    // account details
    let sender_private_key = 1;
    let sender_account = account(sender_private_key);

    // generate commitment
    let in_commitment_bliding = 2;
    let in_commitment = commitment(sender_account, in_commitment_value, in_commitment_bliding);
    let in_commitment_nullifier = nullifier(in_commitment, in_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_sender_commitment_bliding = 3;
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_commitment_value, out_receiver_commitment_bliding);
    let out_sender_commitment = commitment(sender_account, out_sender_commitment_value, out_sender_commitment_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
    let out_root = hash([new_first_level_l, new_first_level_r], 2);

    // nullifier
    let in_commitment_path = [1, old_first_level_r];
    let in_commitment_direction_selector = [false, false];

    main(
        sender_private_key,
        receiver_account,
        in_commitment_root,
        in_commitment_path,
        in_commitment_direction_selector,
        in_commitment_value,
        in_commitment_bliding,
        in_commitment_nullifier,
        out_receiver_commitment_value,
        out_receiver_commitment_bliding,
        out_receiver_commitment,
        out_sender_commitment_value,
        out_sender_commitment_bliding,
        out_sender_commitment,
        out_root,
        [new_first_level_l],
        [true],
    );
}

#[test(should_fail_with = "Invalid UTXO amounts")]
fn test_invalid_utxo_amounts() {
    // generate amounts
    let in_commitment_value = 10;
    let out_receiver_commitment_value = 2;
    let out_sender_commitment_value = 8000; // // <-------------------------------------------- out more than it should

    // account details
    let sender_private_key = 1;
    let sender_account = account(sender_private_key);

    // generate commitment
    let in_commitment_bliding = 2;
    let in_commitment = commitment(sender_account, in_commitment_value, in_commitment_bliding);
    let in_commitment_nullifier = nullifier(in_commitment, in_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_sender_commitment_bliding = 3;
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_commitment_value, out_receiver_commitment_bliding);
    let out_sender_commitment = commitment(sender_account, out_sender_commitment_value, out_sender_commitment_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
    let out_root = hash([new_first_level_l, new_first_level_r], 2);

    // nullifier
    let in_commitment_path = [1, old_first_level_r];
    let in_commitment_direction_selector = [false, false];

    main(
        sender_private_key,
        receiver_account,
        in_commitment_root,
        in_commitment_path,
        in_commitment_direction_selector,
        in_commitment_value,
        in_commitment_bliding,
        in_commitment_nullifier,
        out_receiver_commitment_value,
        out_receiver_commitment_bliding,
        out_receiver_commitment,
        out_sender_commitment_value,
        out_sender_commitment_bliding,
        out_sender_commitment,
        out_root,
        [new_first_level_l],
        [true],
    );
}

#[test(should_fail)]
fn test_unlinked_root() {
    // generate amounts
    let in_commitment_value = 10;
    let out_receiver_commitment_value = 2;
    let out_sender_commitment_value = 8000; // Notice here

    // account details
    let sender_private_key = 1;
    let sender_account = account(sender_private_key);

    // generate commitment
    let in_commitment_bliding = 2;
    let in_commitment = commitment(sender_account, in_commitment_value, in_commitment_bliding);
    let in_commitment_nullifier = nullifier(in_commitment, in_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_sender_commitment_bliding = 3;
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_commitment_value, out_receiver_commitment_bliding);
    let out_sender_commitment = commitment(sender_account, out_sender_commitment_value, out_sender_commitment_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([100000, 1], 2); // <-------------------------------------------- Removed in commitment
    let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
    let out_root = hash([new_first_level_l, new_first_level_r], 2);

    // nullifier
    let in_commitment_path = [1, old_first_level_r];
    let in_commitment_direction_selector = [false, false];

    main(
        sender_private_key,
        receiver_account,
        in_commitment_root,
        in_commitment_path,
        in_commitment_direction_selector,
        in_commitment_value,
        in_commitment_bliding,
        in_commitment_nullifier,
        out_receiver_commitment_value,
        out_receiver_commitment_bliding,
        out_receiver_commitment,
        out_sender_commitment_value,
        out_sender_commitment_bliding,
        out_sender_commitment,
        out_root,
        [new_first_level_l],
        [true],
    );
}

#[test(should_fail)]
fn test_missing_new_commits() {
    // generate amounts
    let in_commitment_value = 10;
    let out_receiver_commitment_value = 2;
    let out_sender_commitment_value = 8000; // Notice here

    // account details
    let sender_private_key = 1;
    let sender_account = account(sender_private_key);

    // generate commitment
    let in_commitment_bliding = 2;
    let in_commitment = commitment(sender_account, in_commitment_value, in_commitment_bliding);
    let in_commitment_nullifier = nullifier(in_commitment, in_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_sender_commitment_bliding = 3;
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_commitment_value, out_receiver_commitment_bliding);
    let out_sender_commitment = commitment(sender_account, out_sender_commitment_value, out_sender_commitment_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([0, 0], 2); // <-------------------------------------------- Missing new commitments
    let out_root = hash([new_first_level_l, new_first_level_r], 2);

    // nullifier
    let in_commitment_path = [1, old_first_level_r];
    let in_commitment_direction_selector = [false, false];

    main(
        sender_private_key,
        receiver_account,
        in_commitment_root,
        in_commitment_path,
        in_commitment_direction_selector,
        in_commitment_value,
        in_commitment_bliding,
        in_commitment_nullifier,
        out_receiver_commitment_value,
        out_receiver_commitment_bliding,
        out_receiver_commitment,
        out_sender_commitment_value,
        out_sender_commitment_bliding,
        out_sender_commitment,
        out_root,
        [new_first_level_l],
        [true],
    );
}
