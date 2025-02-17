use starknet::{
    storage::{StoragePointerWriteAccess, StoragePathEntry, StoragePointerReadAccess},
    ContractAddress,
};
use snforge_std::{
    spy_events, EventSpyAssertionsTrait, declare, ContractClassTrait, DeclareResultTrait,
    test_address, EventSpyTrait,
};
use contracts::privado::{Privado, IPrivado, constants::{TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS}};


#[test]
fn test_transfer() {
    let (mut contract, contract_address) = get_contract_state_for_testing();

    let in_commitment_root = 0;
    let in_commitment_nullifier = 2;
    let out_root = 1;
    let out_sender_commitment = 3;
    let out_receiver_commitment = 4;
    let proof = generate_mock_proof(
        in_commitment_root,
        out_root,
        in_commitment_nullifier,
        out_sender_commitment,
        out_receiver_commitment,
    );
    let current_commitment_index = contract.current_commitment_index.read();

    let mut spy = spy_events();

    // call transfer
    contract.transfer(proof, array!["enc_notes_output_owner", "enc_notes_output_receiver"].span());

    // should nullify the in_commitment_nullifier
    assert(
        contract.nullifiers.entry(in_commitment_nullifier.into()).read() == true,
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
                            commitment: out_sender_commitment.into(),
                            output_enc: "enc_notes_output_owner",
                            index: current_commitment_index,
                        },
                    ),
                ),
                (
                    contract_address,
                    Privado::Event::NewCommitment(
                        Privado::NewCommitment {
                            commitment: out_receiver_commitment.into(),
                            output_enc: "enc_notes_output_receiver",
                            index: current_commitment_index + 1,
                        },
                    ),
                ),
                (
                    contract_address,
                    Privado::Event::NewNullifier(
                        Privado::NewNullifier { nullifier: in_commitment_nullifier.into() },
                    ),
                ),
            ],
        );
    assert(spy.get_events().events.len() == 3, 'There should no more events');
}

#[test]
#[should_panic(expected: 'Cannot find your merkle root')]
fn test_transfer_unknown_root() {
    let (mut contract, _) = get_contract_state_for_testing();

    let in_commitment_root = 0;
    let out_root = 1;
    let in_commitment_nullifier = 2;
    let out_sender_commitment = 3;
    let out_receiver_commitment = 4;
    let proof = generate_mock_proof(
        in_commitment_root,
        out_root,
        in_commitment_nullifier,
        out_sender_commitment,
        out_receiver_commitment,
    );

    // differ from proof
    contract.current_root.write((in_commitment_root + 10).into());

    // call transfer
    contract.transfer(proof, array!["enc_notes_output_owner", "enc_notes_output_receiver"].span());
}

#[test]
#[should_panic(expected: 'Note already spent')]
fn test_transfer_double_spent() {
    let (mut contract, _) = get_contract_state_for_testing();

    let in_commitment_root = 0;
    let out_root = 1;
    let in_commitment_nullifier = 2;
    let out_sender_commitment = 3;
    let out_receiver_commitment = 4;
    let proof = generate_mock_proof(
        in_commitment_root,
        out_root,
        in_commitment_nullifier,
        out_sender_commitment,
        out_receiver_commitment,
    );

    // mark the commitment as already spent
    contract.nullifiers.entry(in_commitment_nullifier.into()).write(true);

    // call transfer
    contract.transfer(proof, array!["enc_notes_output_owner", "enc_notes_output_receiver"].span());
}

//
// utilities
//

fn generate_mock_proof(
    in_commitment_root: felt252,
    out_root: felt252,
    nullifier: felt252,
    sender_commitment: felt252,
    receiver_commitment: felt252,
) -> Span<felt252> {
    array![in_commitment_root, nullifier, receiver_commitment, sender_commitment, out_root].span()
}

fn get_contract_state_for_testing() -> (Privado::ContractState, ContractAddress) {
    let mut dispatcher = Privado::contract_state_for_testing();

    let transfer_verifier_contract = declare("TransferVerifierMock").unwrap().contract_class();
    let (transfer_verifier_address, _) = transfer_verifier_contract.deploy(@array![]).unwrap();

    let approve_verifier_contract = declare("ApproveVerifierMock").unwrap().contract_class();
    let (approve_verifier_address, _) = approve_verifier_contract.deploy(@array![]).unwrap();

    let transfer_from_verifier_contract = declare("TransferFromVerifierMock")
        .unwrap()
        .contract_class();
    let (transfer_from_verifier_address, _) = transfer_from_verifier_contract
        .deploy(@array![])
        .unwrap();

    // initialize metadata
    dispatcher.name.write(TOKEN_NAME);
    dispatcher.symbol.write(TOKEN_SYMBOL);
    dispatcher.decimals.write(TOKEN_DECIMALS);

    // initialize merkle tree without minting
    dispatcher.current_root.write(0);

    // set the verifier address
    dispatcher.transfer_verifier_address.write(transfer_verifier_address);
    dispatcher.approve_verifier_address.write(approve_verifier_address);
    dispatcher.transfer_from_verifier_address.write(transfer_from_verifier_address);

    (dispatcher, test_address())
}
