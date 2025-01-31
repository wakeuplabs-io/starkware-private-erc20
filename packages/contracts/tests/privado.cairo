use starknet::storage::StoragePointerReadAccess;
use starknet::storage::StoragePathEntry;
use snforge_std::EventSpyTrait;
use contracts::merkle_tree::merkle_tree::IMerkleTreeWithHistory;
use contracts::privado::privado::IPrivado;
use starknet::storage::StoragePointerWriteAccess;
use starknet::ContractAddress;
use snforge_std::{
    spy_events, EventSpyAssertionsTrait, declare, ContractClassTrait, DeclareResultTrait,
    test_address,
};
use contracts::privado::{
    Privado, Privado::InternalTrait, IPrivadoDispatcher, IPrivadoDispatcherTrait,
};
use core::poseidon::PoseidonTrait;
use core::hash::{HashStateTrait, HashStateExTrait};

const TOKEN_NAME: felt252 = 'Token Name';
const TOKEN_SYMBOL: felt252 = 'SYM';
const TOKEN_DECIMALS: u8 = 6;
const LEVELS: usize = 2;

fn generate_commitment(
    secret: felt252, nullifier: felt252, amount: felt252,
) -> (felt252, felt252, felt252) {
    // just a mock
    (
        PoseidonTrait::new().update_with([nullifier, secret, amount]).finalize(),
        amount,
        PoseidonTrait::new().update_with([nullifier]).finalize(),
    )
}

fn get_contract_state_for_testing() -> (Privado::ContractState, ContractAddress) {
    let mut dispatcher = Privado::contract_state_for_testing();

    // initialize metadata
    dispatcher.name.write(TOKEN_NAME);
    dispatcher.symbol.write(TOKEN_SYMBOL);
    dispatcher.decimals.write(TOKEN_DECIMALS);

    // initialize merkle tree without minting
    dispatcher.merkle_tree.initialize(2);

    (dispatcher, test_address())
}

#[test]
fn test_constructor() {
    let contract = declare("Privado").unwrap().contract_class();

    let mut spy = spy_events();

    let (mint_commitment, mint_commitment_amount, _) = generate_commitment(1, 2, 3);
    let (contract_address, _) = contract
        .deploy(
            @array![
                TOKEN_NAME,
                TOKEN_SYMBOL,
                TOKEN_DECIMALS.into(),
                LEVELS.into(),
                mint_commitment,
                mint_commitment_amount,
            ],
        )
        .unwrap();
    let dispatcher = IPrivadoDispatcher { contract_address };

    // metadata
    assert(dispatcher.name() == TOKEN_NAME, 'Invalid name');
    assert(dispatcher.symbol() == TOKEN_SYMBOL, 'Invalid symbol');
    assert(dispatcher.decimals() == TOKEN_DECIMALS, 'Invalid decimals');

    // minted commitment
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Privado::Event::NewNote(
                        Privado::NewNote {
                            commitment: mint_commitment,
                            amount_enc: mint_commitment_amount,
                            index: 1 // next_index
                        },
                    ),
                ),
            ],
        );
    assert(spy.get_events().events.len() == 1, 'There should no more events');
}

// transfer tests

#[test]
fn test_transfer() {
    let (mut contract, contract_address) = get_contract_state_for_testing();

    // generate the minted note and the
    let (secret, nullifier, amount) = (1, 2, 3);
    let (sender_in_commitment, sender_in_amount, sender_in_nullifier_hash) = generate_commitment(
        secret, nullifier, amount,
    );
    contract._create_note(sender_in_commitment, sender_in_amount);

    // generate the outcome commitments
    let (secret, nullifier, amount) = (4, 5, 6);
    let (sender_out_commitment, sender_out_amount, _) = generate_commitment(
        secret, nullifier, amount,
    );
    let (secret, nullifier, amount) = (4, 5, 6);
    let (receiver_out_commitment, receiver_out_amount, _) = generate_commitment(
        secret, nullifier, amount,
    );

    let mut spy = spy_events();

    // call transfer
    contract
        .transfer(
            contract.merkle_tree.get_last_root(),
            sender_in_nullifier_hash,
            sender_out_commitment,
            sender_out_amount,
            receiver_out_commitment,
            receiver_out_amount,
        );

    // should nullify the sender_in_nullifier_hash
    assert(
        contract.nullified_notes.entry(sender_in_nullifier_hash).read() == true,
        'Sender commitment not nullified',
    );

    // should emit notes events to rebuild tree locally
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Privado::Event::NewNote(
                        Privado::NewNote {
                            commitment: sender_out_commitment,
                            amount_enc: sender_out_amount,
                            index: 2,
                        },
                    ),
                ),
                (
                    contract_address,
                    Privado::Event::NewNote(
                        Privado::NewNote {
                            commitment: receiver_out_commitment,
                            amount_enc: receiver_out_amount,
                            index: 3,
                        },
                    ),
                ),
            ],
        );
    assert(spy.get_events().events.len() == 2, 'There should no more events');
}

#[test]
#[should_panic(expected: 'Cannot find your merkle root')]
fn test_transfer_unknown_root() {
    let (mut contract, _) = get_contract_state_for_testing();

    // generate the minted note and the
    let (secret, nullifier, amount) = (1, 2, 3);
    let (sender_in_commitment, sender_in_amount, sender_in_nullifier_hash) = generate_commitment(
        secret, nullifier, amount,
    );
    contract._create_note(sender_in_commitment, sender_in_amount);

    // generate the outcome commitments
    let (secret, nullifier, amount) = (4, 5, 6);
    let (sender_out_commitment, sender_out_amount, _) = generate_commitment(
        secret, nullifier, amount,
    );
    let (secret, nullifier, amount) = (4, 5, 6);
    let (receiver_out_commitment, receiver_out_amount, _) = generate_commitment(
        secret, nullifier, amount,
    );

    // call transfer
    contract
        .transfer(
            contract.merkle_tree.get_last_root() + 10,
            sender_in_nullifier_hash,
            sender_out_commitment,
            sender_out_amount,
            receiver_out_commitment,
            receiver_out_amount,
        );
}


#[test]
#[should_panic(expected: 'Note already spent')]
fn test_transfer_double_spent() {
    let (mut contract, _) = get_contract_state_for_testing();

    // generate the minted note and the
    let (secret, nullifier, amount) = (1, 2, 3);
    let (sender_in_commitment, sender_in_amount, sender_in_nullifier_hash) = generate_commitment(
        secret, nullifier, amount,
    );
    contract._create_note(sender_in_commitment, sender_in_amount);

    // generate the outcome commitments
    let (secret, nullifier, amount) = (4, 5, 6);
    let (sender_out_commitment, sender_out_amount, _) = generate_commitment(
        secret, nullifier, amount,
    );
    let (secret, nullifier, amount) = (4, 5, 6);
    let (receiver_out_commitment, receiver_out_amount, _) = generate_commitment(
        secret, nullifier, amount,
    );

    // call transfer
    contract
        .transfer(
            contract.merkle_tree.get_last_root(),
            sender_in_nullifier_hash,
            sender_out_commitment,
            sender_out_amount,
            receiver_out_commitment,
            receiver_out_amount,
        );
    contract
        .transfer(
            contract.merkle_tree.get_last_root(),
            sender_in_nullifier_hash,
            sender_out_commitment,
            sender_out_amount,
            receiver_out_commitment,
            receiver_out_amount,
        );
}

