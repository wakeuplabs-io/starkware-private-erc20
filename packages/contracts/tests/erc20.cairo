use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use contracts::IErc20SafeDispatcher;
use contracts::IErc20SafeDispatcherTrait;
use contracts::IErc20Dispatcher;
use contracts::IErc20DispatcherTrait;

fn deploy_contract() -> (IErc20Dispatcher, ContractAddress) {
    let contract = declare("Erc20").unwrap().contract_class();

    let token_name: felt252 = 'Token Name';
    let constructor_calldata: Array<felt252> = array![token_name];

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    let dispatcher = IErc20Dispatcher { contract_address };

    (dispatcher, contract_address)
}

#[test]
fn test_name() {
    let (dispatcher, _) = deploy_contract();

    let retrieved_name = dispatcher.name();
    assert(retrieved_name == 'Token Name', 'Invalid name');
}
