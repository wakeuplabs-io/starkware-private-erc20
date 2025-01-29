use starknet::ContractAddress;
use starknet::{contract_address_const};
use snforge_std::{
    start_cheat_caller_address, spy_events, EventSpyAssertionsTrait, declare, ContractClassTrait,
    DeclareResultTrait,
};
use contracts::IMerkleTreeWithHistoryDispatcher;
use contracts::IMerkleTreeWithHistoryDispatcherTrait;

fn deploy_contract() -> (IMerkleTreeWithHistoryDispatcher, ContractAddress) {
    let contract = declare("MerkleTreeWithHistory").unwrap().contract_class();

    let levels: usize = 6;
    let constructor_calldata: Array<felt252> = array![levels.into()];

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    let dispatcher = IMerkleTreeWithHistoryDispatcher { contract_address };

    (dispatcher, contract_address)
}

#[test]
fn test_constructor() {
    let (dispatcher, _) = deploy_contract();

    let last_root = dispatcher.get_last_root();
    println!("{:?}", last_root);
}
