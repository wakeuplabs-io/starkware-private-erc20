use common::definitions::{
    account, allowance_hash, allowance_relationship, commitment, commitment_tracker,
};
use common::merkle_tree::assert_merkle_inclusion;
use std::hash::poseidon2::Poseidon2::hash;

// TODO: update before deploying. So far haven't found way to override for testing
global DEPTH: u32 = 2;

pub fn main(
    // account details
    owner_account: Field,
    receiver_account: Field,
    spender_private_key: Field,
    // input commitment details
    in_commitment_root: pub Field,
    in_commitment_path: [Field; DEPTH],
    in_commitment_direction_selector: [bool; DEPTH],
    in_commitment_bliding: Field,
    in_commitment_value: Field,
    in_commitment_spending_tracker: pub Field,
    // allowance utxo details
    in_allowance_value: Field,
    in_allowance_hash: pub Field,
    in_allowance_relationship: pub Field,
    out_allowance_hash: pub Field,
    // out receiver commitment detailsa
    out_receiver_value: Field,
    out_receiver_bliding: Field,
    out_receiver_commitment: pub Field,
    // out owner commitment details
    out_owner_value: Field,
    out_owner_bliding: Field,
    out_owner_commitment: pub Field,
    // output commitment details
    out_root: pub Field,
    out_subtree_root_path: [Field; DEPTH - 1], // path of hash(out_owner_commitment, out_receiver_commitment)
    out_subtree_direction_selector: [bool; DEPTH - 1], // path direction of hash(out_owner_commitment, out_receiver_commitment)
) {
    // check in_commitment is included in the root and belongs to sender
    let in_commitment = commitment(owner_account, in_commitment_value, in_commitment_bliding);
    assert_merkle_inclusion(
        in_commitment_root,
        in_commitment_path,
        in_commitment_direction_selector,
        in_commitment,
        "Cannot find input commitment",
    );

    // check spending tracker to properly nullify commitment is correct
    assert_eq(
        in_commitment_spending_tracker,
        commitment_tracker(in_commitment, in_commitment_bliding),
        "Invalid spending tracker",
    );

    // check input allowance hash is correct and so we can trust allowance amount. And relationship so we can trust update after
    let spender_account = account(spender_private_key);
    assert_eq(
        in_allowance_hash,
        allowance_hash(owner_account, spender_account, in_allowance_value),
        "Invalid input allowance hash",
    );
    assert_eq(
        in_allowance_relationship,
        allowance_relationship(owner_account, spender_account),
        "Invalid allowance relationship",
    );

    // check commitments utxo
    assert_eq(in_commitment_value, out_receiver_value + out_owner_value, "Invalid UTXO amounts");

    // check allowance utxo
    let out_allowance_value = in_allowance_value - out_receiver_value;
    assert_eq(
        out_allowance_hash,
        allowance_hash(owner_account, spender_account, out_allowance_value),
        "Invalid output allowance hash",
    );

    // validate commitment amounts and receivers are correct
    assert_eq(
        commitment(owner_account, out_owner_value, out_owner_bliding),
        out_owner_commitment,
        "Invalid owner output commitment",
    );
    assert_eq(
        commitment(receiver_account, out_receiver_value, out_receiver_bliding),
        out_receiver_commitment,
        "Invalid receiver output commitment",
    );

    // check we're inserting in a previously empty subtree
    let zero_subtree_root = hash([0, 0], 2);
    assert_merkle_inclusion(
        in_commitment_root,
        out_subtree_root_path,
        out_subtree_direction_selector,
        zero_subtree_root,
        "Missing commitments from old tree in new tree",
    );

    // check newly inserted commitments belong to out_root
    let new_subtree_root = hash([out_owner_commitment, out_receiver_commitment], 2);
    assert_merkle_inclusion(
        out_root,
        out_subtree_root_path,
        out_subtree_direction_selector,
        new_subtree_root,
        "New commits don't belong to new root",
    );
}

#[test]
fn test_allowed_transfer() {
    // generate input amounts
    let in_commitment_value = 10;
    let in_allowance_value = 10;

    // output amounts
    let out_receiver_value = 2;
    let out_owner_value = in_commitment_value - out_receiver_value;
    let out_allowance_value = in_allowance_value - out_receiver_value;

    // accounts details
    let spender_private_key = 0;
    let spender_account = account(spender_private_key);
    let owner_account = account(1);

    // generate commitment
    let in_commitment_bliding = 2;
    let in_commitment = commitment(owner_account, in_commitment_value, in_commitment_bliding);
    let in_commitment_spending_tracker = commitment_tracker(in_commitment, in_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_owner_bliding = 3;
    let out_receiver_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_value, out_receiver_bliding);
    let out_owner_commitment = commitment(owner_account, out_owner_value, out_owner_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);
    let in_commitment_path = [1, old_first_level_r];
    let in_commitment_direction_selector = [false, false];

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([out_owner_commitment, out_receiver_commitment], 2);
    let out_root = hash([new_first_level_l, new_first_level_r], 2);
    let out_subtree_root_path = [new_first_level_l];
    let out_subtree_direction_selector = [true];

    // in_allowance_hash
    let in_allowance_hash = allowance_hash(owner_account, spender_account, in_allowance_value);
    let out_allowance_hash = allowance_hash(owner_account, spender_account, out_allowance_value);
    let in_allowance_relationship = allowance_relationship(owner_account, spender_account);

    main(
        // input commitment details
        owner_account,
        receiver_account,
        spender_private_key,
        in_commitment_root,
        in_commitment_path,
        in_commitment_direction_selector,
        in_commitment_bliding,
        in_commitment_value,
        in_commitment_spending_tracker,
        // allowance utxo details
        in_allowance_value,
        in_allowance_hash,
        in_allowance_relationship,
        out_allowance_hash,
        // out receiver commitment details
        out_receiver_value,
        out_receiver_bliding,
        out_receiver_commitment,
        // out owner commitment details
        out_owner_value,
        out_owner_bliding,
        out_owner_commitment,
        // output commitment details
        out_root,
        out_subtree_root_path,
        out_subtree_direction_selector,
    );
}

#[test(should_fail_with = "Invalid UTXO amounts")]
fn test_invalid_utxo_amounts() {
    // generate input amounts
    let in_commitment_value = 10;
    let in_allowance_value = 10;

    // output amounts
    let out_receiver_value = 2;
    let out_owner_value = 100; // <------------ Should be: in_commitment_value - out_receiver_value;
    let out_allowance_value = in_allowance_value - out_receiver_value;

    // accounts details
    let spender_private_key = 0;
    let spender_account = account(spender_private_key);
    let owner_account = account(1);

    // generate commitment
    let in_commitment_bliding = 2;
    let in_commitment = commitment(owner_account, in_commitment_value, in_commitment_bliding);
    let in_commitment_spending_tracker = commitment_tracker(in_commitment, in_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_owner_bliding = 3;
    let out_receiver_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_value, out_receiver_bliding);
    let out_owner_commitment = commitment(owner_account, out_owner_value, out_owner_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);
    let in_commitment_path = [1, old_first_level_r];
    let in_commitment_direction_selector = [false, false];

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([out_owner_commitment, out_receiver_commitment], 2);
    let out_root = hash([new_first_level_l, new_first_level_r], 2);
    let out_subtree_root_path = [new_first_level_l];
    let out_subtree_direction_selector = [true];

    // in_allowance_hash
    let in_allowance_hash = allowance_hash(owner_account, spender_account, in_allowance_value);
    let out_allowance_hash = allowance_hash(owner_account, spender_account, out_allowance_value);
    let in_allowance_relationship = allowance_relationship(owner_account, spender_account);

    main(
        // input commitment details
        owner_account,
        receiver_account,
        spender_private_key,
        in_commitment_root,
        in_commitment_path,
        in_commitment_direction_selector,
        in_commitment_bliding,
        in_commitment_value,
        in_commitment_spending_tracker,
        // allowance utxo details
        in_allowance_value,
        in_allowance_hash,
        in_allowance_relationship,
        out_allowance_hash,
        // out receiver commitment details
        out_receiver_value,
        out_receiver_bliding,
        out_receiver_commitment,
        // out owner commitment details
        out_owner_value,
        out_owner_bliding,
        out_owner_commitment,
        // output commitment details
        out_root,
        out_subtree_root_path,
        out_subtree_direction_selector,
    );
}

#[test(should_fail_with = "Missing commitments from old tree in new tree")]
fn test_remove_existing_commitments() {
    // generate input amounts
    let in_commitment_value = 10;
    let in_allowance_value = 10;

    // output amounts
    let out_receiver_value = 2;
    let out_owner_value = in_commitment_value - out_receiver_value;
    let out_allowance_value = in_allowance_value - out_receiver_value;

    // accounts details
    let spender_private_key = 0;
    let spender_account = account(spender_private_key);
    let owner_account = account(1);

    // generate commitment
    let in_commitment_bliding = 2;
    let in_commitment = commitment(owner_account, in_commitment_value, in_commitment_bliding);
    let in_commitment_spending_tracker = commitment_tracker(in_commitment, in_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_owner_bliding = 3;
    let out_receiver_bliding = 3;
    let out_receiver_commitment =
        commitment(receiver_account, out_receiver_value, out_receiver_bliding);
    let out_owner_commitment = commitment(owner_account, out_owner_value, out_owner_bliding);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);
    let in_commitment_path = [1, old_first_level_r];
    let in_commitment_direction_selector = [false, false];

    // new tree
    let new_first_level_l = hash([0, 1], 2); // <------------------------ removed input_commitment
    let new_first_level_r = hash([out_owner_commitment, out_receiver_commitment], 2);
    let out_root = hash([new_first_level_l, new_first_level_r], 2);
    let out_subtree_root_path = [new_first_level_l];
    let out_subtree_direction_selector = [true];

    // in_allowance_hash
    let in_allowance_hash = allowance_hash(owner_account, spender_account, in_allowance_value);
    let out_allowance_hash = allowance_hash(owner_account, spender_account, out_allowance_value);
    let in_allowance_relationship = allowance_relationship(owner_account, spender_account);

    main(
        // input commitment details
        owner_account,
        receiver_account,
        spender_private_key,
        in_commitment_root,
        in_commitment_path,
        in_commitment_direction_selector,
        in_commitment_bliding,
        in_commitment_value,
        in_commitment_spending_tracker,
        // allowance utxo details
        in_allowance_value,
        in_allowance_hash,
        in_allowance_relationship,
        out_allowance_hash,
        // out receiver commitment details
        out_receiver_value,
        out_receiver_bliding,
        out_receiver_commitment,
        // out owner commitment details
        out_owner_value,
        out_owner_bliding,
        out_owner_commitment,
        // output commitment details
        out_root,
        out_subtree_root_path,
        out_subtree_direction_selector,
    );
}
