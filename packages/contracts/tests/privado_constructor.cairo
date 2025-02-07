use snforge_std::{
    spy_events, EventSpyAssertionsTrait, declare, ContractClassTrait, DeclareResultTrait,
    EventSpyTrait,
};
use contracts::privado::{
    Privado, IPrivadoDispatcher, IPrivadoDispatcherTrait,
    constants::{
        TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, GET_MINT_COMMITMENT, MERKLE_TREE_INITIAL_ROOT,
    },
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

    assert(dispatcher.current_root() == MERKLE_TREE_INITIAL_ROOT, 'Invalid initial merkle root');
    assert(dispatcher.current_commitment_index() == 2, 'Invalid commitment index');

    // minted commitment
    let (mint_commitment, mint_output_enc) = GET_MINT_COMMITMENT();
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Privado::Event::NewCommitment(
                        Privado::NewCommitment {
                            commitment: mint_commitment, output_enc: mint_output_enc, index: 0,
                        },
                    ),
                ),
                (
                    // emit a null commitment to fill the first subtree
                    contract_address,
                    Privado::Event::NewCommitment(
                        Privado::NewCommitment { commitment: 0, output_enc: "0", index: 1 },
                    ),
                ),
            ],
        );
    assert(spy.get_events().events.len() == 2, 'There should no more events');
}
