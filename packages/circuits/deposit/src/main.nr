use common::definitions::{account, commitment};
use common::merkle_tree::assert_merkle_inclusion;
use std::hash::poseidon2::Poseidon2::hash;

// TODO: update before deploying. So far haven't found way to override for testing
global DEPTH: u32 = 2;

// 0.000001 ETH = 1 ENG
global ENG_TO_ETH_RATE: Field = 1_000_000_000_000;
global ETH_TO_ENG_RATE: Field = 1_000_000_000_000_000_000;
global WEI_TO_ENG: Field = 1_000_000_000_000;

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
    let out_receiver_commitment_value = ((in_public_amount * ETH_TO_ENG_RATE) / ENG_TO_ETH_RATE) / WEI_TO_ENG;
    
    assert_eq(
        commitment(
            receiver_account,
            out_receiver_commitment_value,
            out_receiver_commitment_bliding,
        ),
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
fn test_allowed_deposit() {
    // generate amounts
    let in_public_amount = 500_000_000_000;
    let out_receiver_commitment_value = 500_000;

    // output commitment generation
    let receiver_account = account(100);
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment = commitment(
        receiver_account,
        out_receiver_commitment_value,
        out_receiver_commitment_bliding,
    );

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
    let in_public_amount = 500_000_000_000;
    let out_receiver_commitment_value = 500_000;

    // output commitment generation
    let receiver_account = account(100);
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment = commitment(
        receiver_account,
        out_receiver_commitment_value,
        out_receiver_commitment_bliding,
    );

    // old tree
    let old_first_level_l = hash([0, 0], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([out_receiver_commitment, 0], 2); 
    let new_first_level_r = hash([0, 1], 2); // <---------- Add an extra commitment
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
fn test_missing_new_commits() {
     // generate amounts
    let in_public_amount = 500_000_000_000;
    let out_receiver_commitment_value = 500_000;

    // output commitment generation
    let receiver_account = account(100);
    let out_receiver_commitment_bliding = 3;
    let out_receiver_commitment = commitment(
        receiver_account,
        out_receiver_commitment_value,
        out_receiver_commitment_bliding,
    );

    // old tree
    let old_first_level_l = hash([0, 0], 2);
    let old_first_level_r = hash([0, 0], 2);
    let in_commitment_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([0, 0], 2);  // <---------- Missing new
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
