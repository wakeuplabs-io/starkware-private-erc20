use starknet::{
    storage::{StoragePointerWriteAccess, StoragePathEntry, StoragePointerReadAccess},
    ContractAddress,
};
use snforge_std::{
    spy_events, EventSpyAssertionsTrait, declare, ContractClassTrait, DeclareResultTrait,
    test_address, EventSpyTrait, start_cheat_block_timestamp, stop_cheat_block_timestamp,
};
use contracts::privado::{Privado, IPrivado, constants::{TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS}};


#[test]
fn test_transfer_from() {
    let (mut contract, contract_address) = get_contract_state_for_testing();

    let in_commitment_root = 0;
    let in_commitment_spending_tracker = 1;
    let in_allowance_hash = 2;
    let in_allowance_relationship = 3;
    let out_allowance_hash = 4;
    let out_receiver_commitment = 5;
    let out_owner_commitment = 6;
    let out_root = 7;
    let proof = generate_mock_proof(
        in_commitment_root,
        in_commitment_spending_tracker,
        in_allowance_hash,
        in_allowance_relationship,
        out_allowance_hash,
        out_receiver_commitment,
        out_owner_commitment,
        out_root,
    );
    let current_commitment_index = contract.current_commitment_index.read();

    let mut spy = spy_events();
    let cheat_timestamp: u64 = 100;
    start_cheat_block_timestamp(contract_address, cheat_timestamp);

    // fabricate allowance
    contract.allowances.entry(in_allowance_relationship.into()).write(in_allowance_hash.into());

    // call transfer_from
    contract
        .transfer_from(
            proof,
            array!["enc_notes_output_owner", "enc_notes_output_receiver"].span(),
            array!["enc_approval_output_owner", "enc_approval_output_spender"].span(),
        );

    // should nullify the in_commitment_spending_tracker
    assert(
        contract.spending_trackers.entry(in_commitment_spending_tracker.into()).read() == true,
        'Sender commitment not nullified',
    );

    // should update allowance with out_allowance_hash
    assert(
        contract
            .allowances
            .entry(in_allowance_relationship.into())
            .read() == out_allowance_hash
            .into(),
        'Did not update allowance after',
    );

    // should emit notes events to rebuild tree locally
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Privado::Event::NewCommitment(
                        Privado::NewCommitment {
                            commitment: out_owner_commitment.into(),
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
                    Privado::Event::NewSpendingTracker(
                        Privado::NewSpendingTracker {
                            spending_tracker: in_commitment_spending_tracker.into(),
                        },
                    ),
                ),
                (
                    contract_address,
                    Privado::Event::Approval(
                        Privado::Approval {
                            timestamp: cheat_timestamp,
                            allowance_hash: out_allowance_hash.into(),
                            allowance_relationship: in_allowance_relationship.into(),
                            output_enc_owner: "enc_approval_output_owner",
                            output_enc_spender: "enc_approval_output_spender",
                        },
                    ),
                ),
            ],
        );
    assert(spy.get_events().events.len() == 4, 'There should no more events');
    stop_cheat_block_timestamp(contract_address);
}

#[test]
#[should_panic(expected: 'Cannot find your merkle root')]
fn test_transfer_from_unknown_root() {
    let (mut contract, _) = get_contract_state_for_testing();

    let in_commitment_root = 0;
    let in_commitment_spending_tracker = 1;
    let in_allowance_hash = 2;
    let in_allowance_relationship = 3;
    let out_allowance_hash = 4;
    let out_receiver_commitment = 5;
    let out_owner_commitment = 6;
    let out_root = 7;
    let proof = generate_mock_proof(
        in_commitment_root,
        in_commitment_spending_tracker,
        in_allowance_hash,
        in_allowance_relationship,
        out_allowance_hash,
        out_receiver_commitment,
        out_owner_commitment,
        out_root,
    );

    // fabricate allowance
    contract.allowances.entry(in_allowance_relationship.into()).write(in_allowance_hash.into());

    // fabricate difference from proof
    contract.current_root.write((in_commitment_root + 10).into());

    // call transfer
    contract
        .transfer_from(
            proof,
            array!["enc_notes_output_owner", "enc_notes_output_receiver"].span(),
            array!["enc_approval_output_owner", "enc_approval_output_spender"].span(),
        );
}

#[test]
#[should_panic(expected: 'Note already spent')]
fn test_transfer_double_spent() {
    let (mut contract, _) = get_contract_state_for_testing();

    let in_commitment_root = 0;
    let in_commitment_spending_tracker = 1;
    let in_allowance_hash = 2;
    let in_allowance_relationship = 3;
    let out_allowance_hash = 4;
    let out_receiver_commitment = 5;
    let out_owner_commitment = 6;
    let out_root = 7;
    let proof = generate_mock_proof(
        in_commitment_root,
        in_commitment_spending_tracker,
        in_allowance_hash,
        in_allowance_relationship,
        out_allowance_hash,
        out_receiver_commitment,
        out_owner_commitment,
        out_root,
    );

    // fabricate allowance
    contract.allowances.entry(in_allowance_relationship.into()).write(in_allowance_hash.into());

    // mark the commitment as already spent
    contract.spending_trackers.entry(in_commitment_spending_tracker.into()).write(true);

    // call transfer
    contract
        .transfer_from(
            proof,
            array!["enc_notes_output_owner", "enc_notes_output_receiver"].span(),
            array!["enc_approval_output_owner", "enc_approval_output_spender"].span(),
        );
}

#[test]
#[should_panic(expected: 'Unknown allowance hash')]
fn test_unknown_allowance_hash() {
    let (mut contract, _) = get_contract_state_for_testing();

    let in_commitment_root = 0;
    let in_commitment_spending_tracker = 1;
    let in_allowance_hash = 2;
    let in_allowance_relationship = 3;
    let out_allowance_hash = 4;
    let out_receiver_commitment = 5;
    let out_owner_commitment = 6;
    let out_root = 7;
    let proof = generate_mock_proof(
        in_commitment_root,
        in_commitment_spending_tracker,
        in_allowance_hash,
        in_allowance_relationship,
        out_allowance_hash,
        out_receiver_commitment,
        out_owner_commitment,
        out_root,
    );

    // fabricate difference in allowance
    contract
        .allowances
        .entry(in_allowance_relationship.into())
        .write((in_allowance_hash + 10).into());

    // call transfer
    contract
        .transfer_from(
            proof,
            array!["enc_notes_output_owner", "enc_notes_output_receiver"].span(),
            array!["enc_approval_output_owner", "enc_approval_output_spender"].span(),
        );
}


//
// utilities
//

fn generate_mock_proof(
    in_commitment_root: felt252,
    in_commitment_spending_tracker: felt252,
    in_allowance_hash: felt252,
    in_allowance_relationship: felt252,
    out_allowance_hash: felt252,
    out_receiver_commitment: felt252,
    out_owner_commitment: felt252,
    out_root: felt252,
) -> Span<felt252> {
    array![
        in_commitment_root,
        in_commitment_spending_tracker,
        in_allowance_hash,
        in_allowance_relationship,
        out_allowance_hash,
        out_receiver_commitment,
        out_owner_commitment,
        out_root,
    ]
        .span()
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
