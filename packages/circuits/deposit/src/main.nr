use common::definitions::{account, commitment};
use common::merkle_tree::{assert_merkle_inclusion};
use std::hash::poseidon2::Poseidon2::hash;

// TODO: update before deploying. So far haven't found way to override for testing
global PUBLIC_TO_PRIVATE_FACTOR: Field = 1_000_000_000_000;
global DEPTH: u32 = 2;

pub fn main(
    // accounts details
    receiver_account: Field,
    // utxo inputs
    in_commitment_root: pub Field,
    in_public_amount: pub Field,
    // utxo outputs
    out_receiver_commitment_bliding: Field,
    out_receiver_commitment: pub Field,
    // updated root
    out_root: pub Field,
    out_subtree_root_path: [Field; DEPTH - 1],
    out_subtree_root_direction_selector: [bool; DEPTH - 1],
) {
    // validate commitment amounts and receivers are correct
    let out_receiver_commitment_value = in_public_amount * PUBLIC_TO_PRIVATE_FACTOR;
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
    let new_subtree_root = hash([out_receiver_commitment, 0], 2);
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
    let in_public_amount = 2;
    let out_receiver_commitment_value = in_public_amount * PUBLIC_TO_PRIVATE_FACTOR;
    // account details

    // output commitment generation
    let receiver_account = account(100);
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_commitment_value, out_receiver_commitment_bliding);

    // old tree
    let old_first_level_l = hash([0, 0], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([out_receiver_commitment, 0], 2);
    let new_first_level_r = hash([0, 0], 2);
    let out_root = hash([new_first_level_l, new_first_level_r], 2);


    main(
        receiver_account,
        in_commitment_root,
        in_public_amount,
        out_receiver_commitment_bliding,
        out_receiver_commitment,
        out_root,
        [new_first_level_r],
        [false],
    );
}

#[test(should_fail)]
fn test_unlinked_root() {
    // generate amounts
    let in_commitment_value = 10;
    let out_receiver_commitment_value = 2;
    let in_public_amount = 2000;
    let out_receiver_commitment_value = in_public_amount * PUBLIC_TO_PRIVATE_FACTOR;

    // account details
    let sender_private_key = 1;
    let sender_account = account(sender_private_key);

    // generate commitment
    let in_commitment_bliding = 2;
    let in_commitment = commitment(sender_account, in_commitment_value, in_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_sender_commitment_bliding = 3;
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_commitment_value, out_receiver_commitment_bliding);
    let out_sender_commitment = commitment(sender_account, out_receiver_commitment_value, out_sender_commitment_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([100000, 1], 2); // <-------------------------------------------- Removed in commitment
    let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
    let out_root = hash([new_first_level_l, new_first_level_r], 2);

    main(
        receiver_account,
        in_commitment_root,
        in_public_amount,
        out_receiver_commitment_bliding,
        out_receiver_commitment,
        out_root,
        [new_first_level_l],
        [true],
    );
}

#[test(should_fail)]
fn test_missing_new_commits() {
    // generate amounts
    let in_commitment_value = 10;
    let in_public_amount = 2;
    let out_receiver_commitment_value = in_public_amount * PUBLIC_TO_PRIVATE_FACTOR;

    // account details
    let sender_private_key = 1;
    let sender_account = account(sender_private_key);

    // generate commitment
    let in_commitment_bliding = 2;
    let in_commitment = commitment(sender_account, in_commitment_value, in_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_commitment_value, out_receiver_commitment_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([0, 0], 2); // <-------------------------------------------- Missing new commitments
    let out_root = hash([new_first_level_l, new_first_level_r], 2);

    main(
        receiver_account,
        in_commitment_root,
        in_public_amount,
        out_receiver_commitment_bliding,
        out_receiver_commitment,
        out_root,
        [new_first_level_l],
        [true],
    );
}
