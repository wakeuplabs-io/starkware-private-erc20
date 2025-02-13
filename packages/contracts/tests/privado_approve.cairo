use starknet::{
    storage::{StoragePointerWriteAccess, StoragePathEntry, StoragePointerReadAccess},
    ContractAddress,
};
use snforge_std::{
    spy_events, EventSpyAssertionsTrait, declare, ContractClassTrait, DeclareResultTrait,
    test_address, EventSpyTrait, start_cheat_block_timestamp,
};
use contracts::privado::{Privado, IPrivado, constants::{TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS}};

// transfer tests

#[test]
fn test_approve() {
    let (mut contract, contract_address) = get_contract_state_for_testing();

    let allowance_hash = 1;
    let allowance_relationship = 2;
    let proof = generate_approve_mock_proof(allowance_hash, allowance_relationship);

    let mut spy = spy_events();
    let cheap_timestamp: u64 = 100;
    start_cheat_block_timestamp(contract_address, cheap_timestamp);

    // call transfer
    contract.approve(proof, "owner_enc_output", "spender_enc_output");

    // should update the allowance_hash
    assert(
        contract.allowances.entry(allowance_relationship.into()).read() == allowance_hash.into(),
        'Incorrect approval hash stored',
    );

    // should emit notes events to rebuild tree locally
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Privado::Event::Approval(
                        Privado::Approval {
                            timestamp: cheap_timestamp,
                            allowance_hash: allowance_hash.into(),
                            allowance_relationship: allowance_relationship.into(),
                            output_enc_owner: "owner_enc_output",
                            output_enc_spender: "spender_enc_output",
                        },
                    ),
                )
            ],
        );
    assert(spy.get_events().events.len() == 1, 'There should no more events');
}

//
// utilities
//

fn generate_approve_mock_proof(allowance_hash: felt252, allowance_relationship: felt252) -> Span<felt252> {
    array![allowance_hash, allowance_relationship].span()
}

fn get_contract_state_for_testing() -> (Privado::ContractState, ContractAddress) {
    let mut dispatcher = Privado::contract_state_for_testing();

    let transfer_verifier_contract = declare("TransferVerifierMock").unwrap().contract_class();
    let (transfer_verifier_address, _) = transfer_verifier_contract.deploy(@array![]).unwrap();

    let approve_verifier_contract = declare("ApproveVerifierMock").unwrap().contract_class();
    let (approve_verifier_address, _) = approve_verifier_contract.deploy(@array![]).unwrap();

    // initialize metadata
    dispatcher.name.write(TOKEN_NAME);
    dispatcher.symbol.write(TOKEN_SYMBOL);
    dispatcher.decimals.write(TOKEN_DECIMALS);

    // initialize merkle tree without minting
    dispatcher.current_root.write(0);

    // set the verifier address
    dispatcher.transfer_verifier_address.write(transfer_verifier_address);
    dispatcher.approve_verifier_address.write(approve_verifier_address);

    (dispatcher, test_address())
}
