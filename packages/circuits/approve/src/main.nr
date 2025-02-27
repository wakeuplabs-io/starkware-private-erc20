use common::definitions::{account, allowance_hash, allowance_relationship};
use std::hash::poseidon2::Poseidon2::hash;

fn main(
    in_private_key: Field,
    in_amount: Field,
    in_spender: Field,
    out_allowance_hash: pub Field,
    out_relationship_id: pub Field,
) {
    let owner_address = account(in_private_key);
    assert(out_allowance_hash == allowance_hash(owner_address, in_spender, in_amount));

    assert(out_relationship_id == allowance_relationship(owner_address, in_spender));
}

#[test]
fn test_correct_allowance() {
    let owner_private_key = 1;
    let owner_address = account(owner_private_key);
    let in_amount = 10;
    let in_spender = 20;
    let out_allowance_hash = hash([owner_address, in_spender, in_amount], 3);
    let out_relationship_id = hash([owner_address, in_spender], 2);

    main(
        owner_private_key,
        in_amount,
        in_spender,
        out_allowance_hash,
        out_relationship_id,
    );
}

#[test(should_fail)]
fn test_incorrect_amount() {
    let owner_private_key = 1;
    let owner_address = account(owner_private_key);
    let in_amount = 10;
    let in_spender = 20;
    let out_allowance_hash = hash(
        [owner_address, in_spender, in_amount + 100], // <--- Notice incorrect amount
        3,
    );
    let out_relationship_id = hash([owner_address, in_spender], 2);

    main(
        owner_private_key,
        in_amount,
        in_spender,
        out_allowance_hash,
        out_relationship_id,
    );
}

#[test(should_fail)]
fn test_incorrect_owner() {
    let owner_private_key = 1;
    let owner_address = account(owner_private_key);
    let in_amount = 10;
    let in_spender = 20;
    let out_allowance_hash = hash(
        [account(owner_private_key + 1), in_spender, in_amount], // <--- Notice incorrect private key
        3,
    );
    let out_relationship_id = hash([owner_address, in_spender], 2);

    main(
        owner_private_key,
        in_amount,
        in_spender,
        out_allowance_hash,
        out_relationship_id,
    );
}
