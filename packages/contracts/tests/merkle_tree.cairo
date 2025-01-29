use starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};
use contracts::IMerkleTreeWithHistoryDispatcher;
use contracts::IMerkleTreeWithHistoryDispatcherTrait;
use contracts::hashes::PoseidonCHasher;
use contracts::constants;

fn deploy_contract() -> (IMerkleTreeWithHistoryDispatcher, ContractAddress) {
    let contract = declare("MerkleTreeWithHistory").unwrap().contract_class();

    let levels: usize = 2; // for testing
    let constructor_calldata: Array<felt252> = array![levels.into()];

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    let dispatcher = IMerkleTreeWithHistoryDispatcher { contract_address };

    (dispatcher, contract_address)
}

#[test]
fn test_constructor() {
    let (dispatcher, _) = deploy_contract();

    assert(
        dispatcher
            .get_last_root() == PoseidonCHasher::commutative_hash(
                constants::ZERO_VALUE, constants::ZERO_VALUE,
            ),
        'Error',
    );
    assert(
        dispatcher
            .is_known_root(
                PoseidonCHasher::commutative_hash(constants::ZERO_VALUE, constants::ZERO_VALUE),
            ) == true,
        'Unkown root',
    );
}


#[test]
fn test_insert() {
    let (dispatcher, _) = deploy_contract();

    dispatcher.insert(1);
    assert(
        dispatcher.get_last_root() == PoseidonCHasher::commutative_hash(1, constants::ZERO_VALUE),
        'Error',
    );

    dispatcher.insert(1);
    assert(dispatcher.get_last_root() == PoseidonCHasher::commutative_hash(1, 1), 'Error');
}

#[test]
#[should_panic(expected: 'MT: No more space')]
fn test_insert_full() {
    let (dispatcher, _) = deploy_contract();

    dispatcher.insert(1);
    dispatcher.insert(1);
    dispatcher.insert(1);
    dispatcher.insert(1);
}


#[test]
fn test_in_known_root() {
    let (dispatcher, _) = deploy_contract();

    dispatcher.insert(1);
    assert(
        dispatcher.is_known_root(PoseidonCHasher::commutative_hash(1, constants::ZERO_VALUE)),
        'Couldnt find known root',
    );

    dispatcher.insert(1);
    assert(
        dispatcher.is_known_root(PoseidonCHasher::commutative_hash(1, 1)),
        'Couldnt find known root',
    );

    assert(
        dispatcher.is_known_root(PoseidonCHasher::commutative_hash(100, 100)) == false,
        'Found unknown root',
    );
}
