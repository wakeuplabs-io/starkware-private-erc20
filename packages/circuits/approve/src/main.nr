use std::hash::poseidon2::Poseidon2::hash;

fn main(in_private_key: Field, in_amount: Field, in_spender: Field, out_allowance_hash: pub Field) {
    let address = generate_account(in_private_key);
    assert(out_allowance_hash == allowance_hash_builder(address, in_spender, in_amount));
}

pub fn generate_account(private_key: Field) -> Field {
    hash([private_key], 1)
}

pub fn allowance_hash_builder(address: Field, spender: Field, amount: Field) -> Field {
    hash([address, spender, amount], 3)
}

#[test]
fn test_correct_allowance() {
    let in_private_key = 1;
    let in_amount = 10;
    let in_spender = 20;
    let out_allowance_hash = hash([generate_account(in_private_key), in_spender, in_amount], 3);

    main(in_private_key, in_amount, in_spender, out_allowance_hash);
}

#[test(should_fail)]
fn test_incorrect_amount() {
    let in_private_key = 1;
    let in_amount = 10;
    let in_spender = 20;
    let out_allowance_hash = hash(
        [generate_account(in_private_key), in_spender, in_amount + 100], // <--- Notice incorrect amount
        3,
    );

    main(in_private_key, in_amount, in_spender, out_allowance_hash);
}


#[test(should_fail)]
fn test_incorrect_owner() {
    let in_private_key = 1;
    let in_amount = 10;
    let in_spender = 20;
    let out_allowance_hash = hash(
        [generate_account(in_private_key + 1), in_spender, in_amount], // <--- Notice incorrect private key
        3,
    );

    main(in_private_key, in_amount, in_spender, out_allowance_hash);
}
