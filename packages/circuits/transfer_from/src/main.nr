use common::merkle_tree::assert_merkle_inclusion;
use common::definitions::{account, allowance_hash, allowance_relationship, commitment, commitment_tracker};
use std::hash::poseidon2::Poseidon2::hash;

// TODO: update before deploying. So far haven't found way to override for testing
global DEPTH: u32 = 2;

// address = hash(private_key) // for easier verification in proof
// commitment = hash(address, bliding, amount) // bliding = random number that makes commitment unique
// nullifier = hash(commitment, private_key, path)
// commitment_tracker = hash(commitment, bliding) // same bliding as for commitment

pub fn main(
    // input commitment details
    input_commitment_root: pub Field,
    input_commitment_path: [Field; DEPTH],
    input_commitment_direction_selector: [bool; DEPTH],
    input_commitment_bliding: Field,
    input_commitment_owner: Field,
    input_commitment_amount: Field,
    input_commitment_spending_tracker: pub Field,

    // allowance utxo details
    input_allowance_amount: Field,
    input_allowance_hash: pub Field,
    spender_private_key: Field,
    output_allowance_hash: pub Field, 

    // out receiver commitment details
    receiver_account: Field,
    out_receiver_value: Field,
    out_receiver_bliding: Field,
    out_receiver_commitment: pub Field,

    // out owner commitment details
    out_owner_value: Field,
    out_owner_bliding: Field,
    out_owner_commitment: pub Field,
    
    // output commitment details
    out_root: pub Field,
    out_subtree_root_path: [Field; DEPTH - 1], // path of hash(out_sender_commitment, out_receiver_commitment)
    out_subtree_direction_selector: [bool; DEPTH - 1], // path direction of hash(out_sender_commitment, out_receiver_commitment)
) {
    // check input_commitment is included in the root and belongs to sender
    let input_commitment = commitment(input_commitment_owner, input_commitment_amount, input_commitment_bliding);
    assert_merkle_inclusion(input_commitment_root, input_commitment_path, input_commitment_direction_selector, input_commitment);

    // check spending tracker is correct. TODO: check relationship id
    assert(input_commitment_spending_tracker == commitment_tracker(input_commitment, input_commitment_bliding));

    // check input allowance hash is correct
    let spender_account = account(spender_private_key);
    assert(input_allowance_hash == allowance_hash(input_commitment_owner, spender_account, input_allowance_amount));


    // check commitments utxo
    assert(input_commitment_amount == out_receiver_value + out_owner_value, "Invalid UTXO amounts");

    // check allowance utxo
    let out_allowance_amount = input_allowance_amount - out_receiver_value;
    assert(output_allowance_hash == allowance_hash(input_commitment_owner, spender_account, out_allowance_amount));

    // validate commitment amounts and receivers are correct
    assert(commitment(input_commitment_owner, out_owner_value, out_owner_bliding) == out_owner_commitment);
    assert(commitment(receiver_account,out_receiver_value, out_receiver_bliding) == out_receiver_commitment);

    // check we're inserting in a previously empty subtree
    let zero_subtree_root = hash([0, 0], 2);
    assert_merkle_inclusion(
        input_commitment_root,
        out_subtree_root_path,
        out_subtree_direction_selector,
        zero_subtree_root,
    );

    // check newly inserted commitments belong to new_root
    let new_subtree_root = hash([out_owner_commitment, out_receiver_commitment], 2);
    assert_merkle_inclusion(
        out_root,
        out_subtree_root_path,
        out_subtree_direction_selector,
        new_subtree_root,
    );
}


#[test]
fn test_allowed_transfer() {
    // generate amounts
    let input_commitment_amount = 10;
    let input_allowance_amount = 10;
    let out_receiver_value = 2;
    let out_sender_amount = 8;
    let output_allowance_amount = 8;

    // accounts details
    let spender_private_key = 0;
    let spender_account = account(spender_private_key);
    let input_commitment_owner = account(1);

    // generate commitment
    let input_commitment_bliding = 2;
    let input_commitment = commitment(input_commitment_owner, input_commitment_amount, input_commitment_bliding);
    let input_commitment_spending_tracker = commitment_tracker(input_commitment, input_commitment_bliding);

    // output commitment generation
    let receiver_account = account(100);
    let out_sender_bliding = 3;
    let out_receiver_bliding = 3;
    let out_receiver_commitment = commitment(receiver_account, out_receiver_value, out_receiver_bliding);
    let out_sender_commitment = commitment(input_commitment_owner, out_sender_amount, out_sender_bliding);

    // old tree
    let old_first_level_l = hash([input_commitment, 1], 2);
    let old_first_level_r = hash([0, 0], 2);
    let old_root = hash([old_first_level_l, old_first_level_r], 2);

    // new tree
    let new_first_level_l = hash([input_commitment, 1], 2);
    let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
    let new_root = hash([new_first_level_l, new_first_level_r], 2);

    // input_allowance_hash 
    let input_allowance_hash = allowance_hash(input_commitment_owner, spender_account, input_allowance_amount);
    let output_allowance_hash = allowance_hash(input_commitment_owner, spender_account, output_allowance_amount);

    main(
    // input commitment details
    old_root,
    [ 1, old_first_level_r ],
    [false, false],
    input_commitment_bliding,
    input_commitment_owner,
    input_commitment_amount,
    input_commitment_spending_tracker,

    // allowance utxo details
    input_allowance_amount,
    input_allowance_hash,
    spender_private_key,
    output_allowance_hash, 

    // out receiver commitment details
    receiver_account,
    out_receiver_value,
    out_receiver_bliding,
    out_receiver_commitment,

    // out owner commitment details
    out_sender_amount,
    out_sender_bliding,
    out_sender_commitment,
    
    // output commitment details
    new_root,
    [new_first_level_l],
    [true]
    );
}

// #[test(should_fail_with = "Invalid UTXO amounts")]
// fn test_invalid_utxo_amounts() {
//     // generate amounts
//     let input_commitment_amount = 10;
//     let out_receiver_value = 2;
//     let out_sender_amount = 8000; // // <-------------------------------------------- out more than it should

//     // account details
//     let in_private_key = 1;
//     let sender_account = account(in_private_key);

//     // generate commitment
//     let input_commitment_bliding = 2;
//     let input_commitment = commitment(sender_account, input_commitment_amount, input_commitment_bliding);

//     // output commitment generation
//     let receiver_account = account(100);
//     let out_sender_bliding = 3;
//     let out_receiver_bliding = 3;
//     let out_receiver_commitment = commitment(receiver_account, out_receiver_value, out_receiver_bliding);
//     let out_sender_commitment = commitment(sender_account, out_sender_amount, out_sender_bliding);

//     // old tree
//     let old_first_level_l = hash([input_commitment, 1], 2);
//     let old_first_level_r = hash([0, 0], 2);
//     let old_root = hash([old_first_level_l, old_first_level_r], 2);

//     // new tree
//     let new_first_level_l = hash([input_commitment, 1], 2);
//     let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
//     let new_root = hash([new_first_level_l, new_first_level_r], 2);

//     // nullifier
//     let input_commitment_path = [ 1, old_first_level_r ];
//     let input_commitment_direction = [false, false];
//     let input_commitment_nullifier = nullifier(input_commitment, in_private_key, input_commitment_path);
//     let input_commitment_nullifier_hash = hash([input_commitment_nullifier], 1);

//     main(
//         old_root,
//         input_commitment_path,
//         input_commitment_direction,
//         input_commitment_amount,
//         input_commitment_nullifier_hash,
//         in_private_key,
//         input_commitment_bliding,
//         receiver_account,
//         out_receiver_value,
//         out_receiver_bliding,
//         out_receiver_commitment,
//         out_sender_amount,
//         out_sender_bliding,
//         out_sender_commitment,
//         new_root,
//         [new_first_level_l],
//         [true]
//     );
// }

// #[test(should_fail)]
// fn test_unlinked_root() {
//     // generate amounts
//     let input_commitment_amount = 10;
//     let out_receiver_value = 2;
//     let out_sender_amount = 8000; // Notice here

//     // account details
//     let in_private_key = 1;
//     let sender_account = account(in_private_key);

//     // generate commitment
//     let input_commitment_bliding = 2;
//     let input_commitment = commitment(sender_account, input_commitment_amount, input_commitment_bliding);

//     // output commitment generation
//     let receiver_account = account(100);
//     let out_sender_bliding = 3;
//     let out_receiver_bliding = 3;
//     let out_receiver_commitment = commitment(receiver_account, out_receiver_value, out_receiver_bliding);
//     let out_sender_commitment = commitment(sender_account, out_sender_amount, out_sender_bliding);

//     // old tree
//     let old_first_level_l = hash([input_commitment, 1], 2);
//     let old_first_level_r = hash([0, 0], 2);
//     let old_root = hash([old_first_level_l, old_first_level_r], 2);

//     // new tree
//     let new_first_level_l = hash([100000, 1], 2); // <-------------------------------------------- Removed in commitment
//     let new_first_level_r = hash([out_sender_commitment, out_receiver_commitment], 2);
//     let new_root = hash([new_first_level_l, new_first_level_r], 2);

//     // nullifier
//     let input_commitment_path = [ 1, old_first_level_r ];
//     let input_commitment_direction = [false, false];
//     let input_commitment_nullifier = nullifier(input_commitment, in_private_key, input_commitment_path);
//     let input_commitment_nullifier_hash = hash([input_commitment_nullifier], 1);

//     main(
//         old_root,
//         input_commitment_path,
//         input_commitment_direction,
//         input_commitment_amount,
//         input_commitment_nullifier_hash,
//         in_private_key,
//         input_commitment_bliding,
//         receiver_account,
//         out_receiver_value,
//         out_receiver_bliding,
//         out_receiver_commitment,
//         out_sender_amount,
//         out_sender_bliding,
//         out_sender_commitment,
//         new_root,
//         [new_first_level_l],
//         [true]
//     );
// }
// #[test(should_fail)]
// fn test_missing_new_commits() {
//     // generate amounts
//     let input_commitment_amount = 10;
//     let out_receiver_value = 2;
//     let out_sender_amount = 8000; // Notice here

//     // account details
//     let in_private_key = 1;
//     let sender_account = account(in_private_key);

//     // generate commitment
//     let input_commitment_bliding = 2;
//     let input_commitment = commitment(sender_account, input_commitment_amount, input_commitment_bliding);

//     // output commitment generation
//     let receiver_account = account(100);
//     let out_sender_bliding = 3;
//     let out_receiver_bliding = 3;
//     let out_receiver_commitment = commitment(receiver_account, out_receiver_value, out_receiver_bliding);
//     let out_sender_commitment = commitment(sender_account, out_sender_amount, out_sender_bliding);

//     // old tree
//     let old_first_level_l = hash([input_commitment, 1], 2);
//     let old_first_level_r = hash([0, 0], 2);
//     let old_root = hash([old_first_level_l, old_first_level_r], 2);

//     // new tree
//     let new_first_level_l = hash([input_commitment, 1], 2);
//     let new_first_level_r = hash([0, 0], 2);  // <-------------------------------------------- Missing new commitments
//     let new_root = hash([new_first_level_l, new_first_level_r], 2);

//     // nullifier
//     let input_commitment_path = [ 1, old_first_level_r ];
//     let input_commitment_direction = [false, false];
//     let input_commitment_nullifier = nullifier(input_commitment, in_private_key, input_commitment_path);
//     let input_commitment_nullifier_hash = hash([input_commitment_nullifier], 1);

//     main(
//         old_root,
//         input_commitment_path,
//         input_commitment_direction,
//         input_commitment_amount,
//         input_commitment_nullifier_hash,
//         in_private_key,
//         input_commitment_bliding,
//         receiver_account,
//         out_receiver_value,
//         out_receiver_bliding,
//         out_receiver_commitment,
//         out_sender_amount,
//         out_sender_bliding,
//         out_sender_commitment,
//         new_root,
//         [new_first_level_l],
//         [true]
//     );
// }
