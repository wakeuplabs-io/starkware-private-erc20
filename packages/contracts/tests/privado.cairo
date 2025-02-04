use starknet::{
    storage::{StoragePointerWriteAccess, StoragePathEntry, StoragePointerReadAccess},
    ContractAddress,
};
use snforge_std::{
    spy_events, EventSpyAssertionsTrait, declare, ContractClassTrait, DeclareResultTrait,
    test_address, EventSpyTrait,
};
use contracts::privado::{
    Privado, IPrivadoDispatcher, IPrivadoDispatcherTrait, IPrivado,
    constants::{TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, GET_MINT_COMMITMENT, MERKLE_TREE_INITIAL_ROOT},
};

#[test]
fn test_constructor() {
    let contract = declare("Privado").unwrap().contract_class();

    let mut spy = spy_events();

    let (contract_address, _) = contract.deploy(@array![]).unwrap();
    let dispatcher = IPrivadoDispatcher { contract_address };

    // metadata
    assert(dispatcher.name() == TOKEN_NAME, 'Invalid name');
    assert(dispatcher.symbol() == TOKEN_SYMBOL, 'Invalid symbol');
    assert(dispatcher.decimals() == TOKEN_DECIMALS, 'Invalid decimals');

    assert(dispatcher.current_root() == MERKLE_TREE_INITIAL_ROOT, '');
    assert(dispatcher.current_commitment_index() == 1, '');

    // minted commitment
    let (mint_commitment, mint_amount_enc) = GET_MINT_COMMITMENT();
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Privado::Event::NewCommitment(
                        Privado::NewCommitment {
                            commitment: mint_commitment,
                            amount_enc: mint_amount_enc,
                            index: 0 // next_index
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

    let root = 0;
    let new_root = 1;
    let sender_in_nullifier_hash = 2;
    let sender_out_commitment = 3;
    let receiver_out_commitment = 4;
    let proof = generate_mock_proof(
        root,
        new_root,
        sender_in_nullifier_hash,
        sender_out_commitment,
        receiver_out_commitment
    );
    let current_commitment_index = contract.current_commitment_index.read();

    let mut spy = spy_events();

    // call transfer
    contract
        .transfer(
            proof,
            "sender_enc_output",
            "receiver_enc_output",
        );

    // should nullify the sender_in_nullifier_hash
    assert(
        contract.nullified_notes.entry(sender_in_nullifier_hash.into()).read() == true,
        'Sender commitment not nullified',
    );

    // should emit notes events to rebuild tree locally
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Privado::Event::NewCommitment(
                        Privado::NewCommitment {
                            commitment: sender_out_commitment.into(),
                            amount_enc: "sender_enc_output",
                            index: current_commitment_index,
                        },
                    ),
                ),
                (
                    contract_address,
                    Privado::Event::NewCommitment(
                        Privado::NewCommitment {
                            commitment: receiver_out_commitment.into(),
                            amount_enc: "receiver_enc_output",
                            index: current_commitment_index + 1,
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

    let root = 1234; // unknown root
    let new_root = 1;
    let sender_in_nullifier_hash = 2;
    let sender_out_commitment = 3;
    let receiver_out_commitment = 4;
    let proof = generate_mock_proof(
        root,
        new_root,
        sender_in_nullifier_hash,
        sender_out_commitment,
        receiver_out_commitment
    );

    // call transfer
    contract
        .transfer(
            proof,
            "sender_enc_output",
            "receiver_enc_output",
        );
}


#[test]
#[should_panic(expected: 'Note already spent')]
fn test_transfer_double_spent() {
    let (mut contract, _) = get_contract_state_for_testing();

    let root = 0; 
    let new_root = 1;
    let sender_in_nullifier_hash = 2;
    let sender_out_commitment = 3;
    let receiver_out_commitment = 4;
    let proof = generate_mock_proof(
        root,
        new_root,
        sender_in_nullifier_hash,
        sender_out_commitment,
        receiver_out_commitment
    );

    // mark the commitment as already spent
    contract.nullified_notes.entry(sender_in_nullifier_hash.into()).write(true);

    // call transfer
    contract
        .transfer(
            proof,
            "sender_enc_output",
            "receiver_enc_output",
        );
}

//
// utilities
//

fn generate_mock_proof(root: felt252, new_root: felt252, nullifier_hash: felt252, sender_commitment: felt252, receiver_commitment: felt252) -> Span<felt252> {
    array![root, new_root, nullifier_hash, sender_commitment, receiver_commitment].span()
}

fn deploy_transfer_verifier() -> ContractAddress {
    let contract = declare("TransferVerifierMock").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@array![]).unwrap();

    contract_address
}

fn get_contract_state_for_testing() -> (Privado::ContractState, ContractAddress) {
    let mut dispatcher = Privado::contract_state_for_testing();
    let transfer_verifier_address = deploy_transfer_verifier();

    // initialize metadata
    dispatcher.name.write(TOKEN_NAME);
    dispatcher.symbol.write(TOKEN_SYMBOL);
    dispatcher.decimals.write(TOKEN_DECIMALS);

    // initialize merkle tree without minting
    dispatcher.current_root.write(MERKLE_TREE_INITIAL_ROOT);

    // set the verifier address
    dispatcher.transfer_verifier_address.write(transfer_verifier_address);

    (dispatcher, test_address())
}
