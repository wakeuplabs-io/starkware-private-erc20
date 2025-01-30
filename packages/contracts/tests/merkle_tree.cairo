use starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};
use contracts::merkle_tree::IMerkleTreeWithHistoryDispatcher;
use contracts::merkle_tree::IMerkleTreeWithHistoryDispatcherTrait;
use contracts::merkle_tree::hashes::PoseidonCHasher;
use contracts::merkle_tree::constants;

const MERKLE_TREE_SIZE: usize = 2;

fn deploy_contract() -> (IMerkleTreeWithHistoryDispatcher, ContractAddress) {
    let contract = declare("MockMerkleTreeWithHistory").unwrap().contract_class();

    let (contract_address, _) = contract.deploy(@array![]).unwrap();
    let dispatcher = IMerkleTreeWithHistoryDispatcher { contract_address };

    dispatcher.initialize(MERKLE_TREE_SIZE);

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

    // up to 4 elements because MERKLE_TREE_SIZE = 2
    dispatcher.insert(1);
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
