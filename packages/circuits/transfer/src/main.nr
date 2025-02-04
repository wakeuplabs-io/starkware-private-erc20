mod merkle_tree;
use crate::merkle_tree::assert_merkle_inclusion;
use std::hash::poseidon2::Poseidon2::hash;

global DEPTH: u32 = 2;

// TODO: amount as u32?

pub fn main(
    // utxo inputs
    in_root: pub Field,
    in_path: [Field; DEPTH],
    in_direction_selector: [bool; DEPTH],
    in_amount: Field,
    in_commitment_nullifier: Field,
    in_commitment_nullifier_hash: pub Field,
    in_commitment_secret: Field,
    // utxo outputs
    out_receiver_account: Field,
    out_root: pub Field,
    out_amount_sender: Field,
    out_amount_receiver: Field,
    out_commitment_sender: pub Field,
    out_commitment_receiver: pub Field,
    out_subtree_root_path: [Field; DEPTH - 1], // path of hash(out_commitment_sender, out_commitment_receiver)
    out_subtree_root_direction: [bool; DEPTH - 1] // path direction of hash(out_commitment_sender, out_commitment_receiver)
) {
    // check in_commitment is included in the root and belongs to sender
    let sender_account = generate_account(in_commitment_secret, in_commitment_nullifier);
    let in_commitment = generate_commitment(sender_account, in_amount);
    assert_merkle_inclusion(in_root, in_path, in_direction_selector, in_commitment);

    // check nullifier_hash belongs to nullifier, tied with previous check nullifier derives in commitment
    assert(hash([in_commitment_nullifier], 1) == in_commitment_nullifier_hash);

    // check utxo
    assert(in_amount == out_amount_receiver + out_amount_sender, "Invalid UTXO amounts");
    
    // validate commitment amounts and receivers are correct
    assert(generate_commitment(sender_account, out_amount_sender) == out_commitment_sender);
    assert(generate_commitment(out_receiver_account, out_amount_receiver) == out_commitment_receiver);

    // check we're inserting in a previously empty subtree
    let zero_subtree_root = hash([0, 0], 2);
    assert_merkle_inclusion(in_root, out_subtree_root_path, out_subtree_root_direction, zero_subtree_root);

    // check newly inserted commitments belong to new_root
    let new_subtree_root = hash([out_commitment_sender, out_commitment_receiver], 2);
    assert_merkle_inclusion(out_root, out_subtree_root_path, out_subtree_root_direction, new_subtree_root);
}

pub fn generate_commitment(account: Field, value: Field) -> Field {
    hash([account, value], 2)
}

pub fn generate_account(secret: Field, nullifier: Field) -> Field {
    hash([secret, nullifier], 2)
}

#[test]
fn test_allowed_transfer() {
    // generate amounts
    let in_amount = 10;
    let out_amount_receiver = 2;
    let out_amount_sender = 8;

    // input commitment generation
    let in_commitment_secret = 1;
    let in_commitment_nullifier = 2;
    let in_commitment_nullifier_hash = hash([in_commitment_nullifier], 1);
    let sender_account = generate_account(in_commitment_secret, in_commitment_nullifier);
    let in_commitment = generate_commitment(sender_account, in_amount);

    // output commitment generation
    let receiver_account = generate_account(0, 0);
    let out_commitment_receiver = generate_commitment(receiver_account, out_amount_receiver);
    let out_commitment_sender = generate_commitment(sender_account, out_amount_sender);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let old_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([out_commitment_sender, out_commitment_receiver], 2);
    let new_root = hash([new_first_level_l, new_first_level_r], 2);

    main(
        old_root,
        [ 1, old_first_level_r ],
        [false, false],
        in_amount,
        in_commitment_nullifier,
        in_commitment_nullifier_hash,
        in_commitment_secret,
        receiver_account,
        new_root,
        out_amount_sender,
        out_amount_receiver,
        out_commitment_sender,
        out_commitment_receiver,
        [new_first_level_l],
        [true]
    );
}

#[test(should_fail_with = "Invalid UTXO amounts")]
fn test_invalid_utxo_amounts() {
    // generate amounts
    let in_amount = 10;
    let out_amount_receiver = 2;
    let out_amount_sender = 1000;

    // input commitment generation
    let in_commitment_secret = 1;
    let in_commitment_nullifier = 2;
    let in_commitment_nullifier_hash = hash([in_commitment_nullifier], 1);
    let sender_account = generate_account(in_commitment_secret, in_commitment_nullifier);
    let in_commitment = generate_commitment(sender_account, in_amount);

    // output commitment generation
    let receiver_account = generate_account(0, 0);
    let out_commitment_receiver = generate_commitment(receiver_account, out_amount_receiver);
    let out_commitment_sender = generate_commitment(sender_account, out_amount_sender);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let old_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([out_commitment_sender, out_commitment_receiver], 2);
    let new_root = hash([new_first_level_l, new_first_level_r], 2);

    main(
        old_root,
        [ 1, old_first_level_r ],
        [false, false],
        in_amount,
        in_commitment_nullifier,
        in_commitment_nullifier_hash,
        in_commitment_secret,
        receiver_account,
        new_root,
        out_amount_sender,
        out_amount_receiver,
        out_commitment_sender,
        out_commitment_receiver,
        [new_first_level_l],
        [true]
    );
}



#[test(should_fail)]
fn test_unlinked_root() {
    // generate amounts
    let in_amount = 10;
    let out_amount_receiver = 2;
    let out_amount_sender = 8;

    // input commitment generation
    let in_commitment_secret = 1;
    let in_commitment_nullifier = 2;
    let in_commitment_nullifier_hash = hash([in_commitment_nullifier], 1);
    let sender_account = generate_account(in_commitment_secret, in_commitment_nullifier);
    let in_commitment = generate_commitment(sender_account, in_amount);

    // output commitment generation
    let receiver_account = generate_account(0, 0);
    let out_commitment_receiver = generate_commitment(receiver_account, out_amount_receiver);
    let out_commitment_sender = generate_commitment(sender_account, out_amount_sender);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let old_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([100, 1], 2); // removed in_commitment
    let new_first_level_r = hash([out_commitment_sender, out_commitment_receiver], 2);
    let new_root = hash([new_first_level_l, new_first_level_r], 2);

    main(
        old_root,
        [ 1, old_first_level_r ],
        [false, false],
        in_amount,
        in_commitment_nullifier,
        in_commitment_nullifier_hash,
        in_commitment_secret,
        receiver_account,
        new_root,
        out_amount_sender,
        out_amount_receiver,
        out_commitment_sender,
        out_commitment_receiver,
        [new_first_level_l],
        [true]
    );
}


#[test(should_fail)]
fn test_missing_new_commits() {
    // generate amounts
    let in_amount = 10;
    let out_amount_receiver = 2;
    let out_amount_sender = 8;

    // input commitment generation
    let in_commitment_secret = 1;
    let in_commitment_nullifier = 2;
    let in_commitment_nullifier_hash = hash([in_commitment_nullifier], 1);
    let sender_account = generate_account(in_commitment_secret, in_commitment_nullifier);
    let in_commitment = generate_commitment(sender_account, in_amount);

    // output commitment generation
    let receiver_account = generate_account(0, 0);
    let out_commitment_receiver = generate_commitment(receiver_account, out_amount_receiver);
    let out_commitment_sender = generate_commitment(sender_account, out_amount_sender);

    // old tree
    let old_first_level_l = hash([in_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let old_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree. Note avoid including new commits
    let new_first_level_l = hash([in_commitment, 1], 2);
    let new_first_level_r = hash([0, 0], 2);
    let new_root = hash([new_first_level_l, new_first_level_r], 2);

    main(
        old_root,
        [ 1, old_first_level_r ],
        [false, false],
        in_amount,
        in_commitment_nullifier,
        in_commitment_nullifier_hash,
        in_commitment_secret,
        receiver_account,
        new_root,
        out_amount_sender,
        out_amount_receiver,
        out_commitment_sender,
        out_commitment_receiver,
        [new_first_level_l],
        [true]
    );
}