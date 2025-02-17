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
fn test_deposit() {
    let (mut contract, contract_address) = get_contract_state_for_testing();

    let in_commitment_root = 0;
    let in_public_amount = 1;
    let out_receiver_commitment = 2;
    let out_root = 3;
    let proof = generate_mock_proof(
        in_commitment_root,
        in_public_amount,
        out_receiver_commitment,
        out_root,
    );
    let current_commitment_index = contract.current_commitment_index.read();

    let mut spy = spy_events();

    // call transfer
    contract.deposit(proof,  array!["enc_notes_output_owner", "enc_notes_output_receiver"].span());


    // should emit notes events to rebuild tree locally
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Privado::Event::NewCommitment(
                        Privado::NewCommitment {
                            commitment: out_receiver_commitment.into(),
                            output_enc: "enc_notes_output_owner",
                            index: current_commitment_index,
                        },
                    ),
                ),
                (
                    contract_address,
                    Privado::Event::NewCommitment(
                        Privado::NewCommitment { commitment: 0, output_enc: "0", index: 1 },
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
    let in_public_amount = 1;
    let out_receiver_commitment = 2;
    let out_root = 3;
    let proof = generate_mock_proof(
        in_commitment_root,
        in_public_amount,
        out_receiver_commitment,
        out_root,
    );

    // differ from proof
    contract.current_root.write((in_commitment_root + 10).into());

    // call transfer
    contract.deposit(proof, array!["enc_notes_output_owner"].span());
}

//
// utilities
//

fn generate_mock_proof(
    in_commitment_root: felt252,
    in_public_amount: felt252,
    out_receiver_commitment: felt252,
    out_root: felt252,
) -> Span<felt252> {
    array![in_commitment_root, in_public_amount, out_receiver_commitment, out_root]
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

    let deposit_verifier_contract = declare("DepositVerifierMock").unwrap().contract_class();
    let (deposit_verifier_address, _) = deposit_verifier_contract.deploy(@array![]).unwrap();

    let erc20_token_mock_contract = declare("Erc20TokenMock").unwrap().contract_class();
    let (erc20_token_mock_address, _) = erc20_token_mock_contract.deploy(@array![]).unwrap();

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
    dispatcher.deposit_verifier_address.write(deposit_verifier_address);
    dispatcher.eth_erc20_token.write(erc20_token_mock_address);

    (dispatcher, test_address())
}
