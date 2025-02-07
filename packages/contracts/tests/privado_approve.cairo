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

    let approve_hash = 1;
    let relationship_hash = 2;
    let proof = generate_approve_mock_proof(approve_hash, relationship_hash);
    let enc_outputs = array!["spender_enc_output", "owner_enc_output"].span();

    let mut spy = spy_events();
    let cheap_timestamp: u64 = 100;
    start_cheat_block_timestamp(contract_address, cheap_timestamp);

    // call transfer
    contract.approve(proof, enc_outputs);

    // should nullify the sender_in_nullifier_hash
    assert(
        contract.allowances.entry(relationship_hash.into()).read() == approve_hash.into(),
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
                            approve_hash: approve_hash.into(),
                            relationship_hash: relationship_hash.into(),
                            output_enc: "spender_enc_output",
                        },
                    ),
                ),
                (
                    contract_address,
                    Privado::Event::Approval(
                        Privado::Approval {
                            timestamp: cheap_timestamp,
                            approve_hash: approve_hash.into(),
                            relationship_hash: relationship_hash.into(),
                            output_enc: "owner_enc_output",
                        },
                    ),
                ),
            ],
        );
    assert(spy.get_events().events.len() == enc_outputs.len(), 'There should no more events');
}

//
// utilities
//

fn generate_approve_mock_proof(approve_hash: felt252, relationship_hash: felt252) -> Span<felt252> {
    array![approve_hash, relationship_hash].span()
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
