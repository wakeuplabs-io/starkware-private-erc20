use starknet::ContractAddress;
use starknet::{contract_address_const};
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use contracts::IErc20SafeDispatcher;
use contracts::IErc20SafeDispatcherTrait;
use contracts::IErc20Dispatcher;
use contracts::IErc20DispatcherTrait;

fn deploy_contract() -> (IErc20Dispatcher, ContractAddress) {
    let contract = declare("Erc20").unwrap().contract_class();

    let token_name: felt252 = 'Token Name';
    let token_symbol: felt252 = 'SYM';
    let token_decimals: u8 = 6;
    let initial_supply: felt252 = 100_000_000;
    let recipient: ContractAddress = contract_address_const::<'RECIPIENT'>();
    let constructor_calldata: Array<felt252> = array![
        token_name, token_symbol, token_decimals.into(), recipient.into(), initial_supply.into(),
    ];

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    let dispatcher = IErc20Dispatcher { contract_address };

    (dispatcher, contract_address)
}

#[test]
fn test_constructor() {
    let (dispatcher, _) = deploy_contract();

    let retrieved_name = dispatcher.name();
    assert(retrieved_name == 'Token Name', 'Invalid name');

    let retrieved_symbol = dispatcher.symbol();
    assert(retrieved_symbol == 'SYM', 'Invalid symbol');

    let retrieved_decimals = dispatcher.decimals();
    assert(retrieved_decimals == 6, 'Invalid decimals');

    let recipient: ContractAddress = contract_address_const::<'RECIPIENT'>();
    let balance_of_recipient = dispatcher.balance_of(recipient);
    assert(balance_of_recipient == 100_000_000, 'Invalid initial balance')
}

