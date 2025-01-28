use starknet::ContractAddress;
use starknet::{contract_address_const};
use snforge_std::{
    start_cheat_caller_address, spy_events, EventSpyAssertionsTrait, declare, ContractClassTrait,
    DeclareResultTrait,
};


use contracts::IErc20SafeDispatcher;
use contracts::IErc20SafeDispatcherTrait;
use contracts::IErc20Dispatcher;
use contracts::IErc20DispatcherTrait;
use contracts::erc20::Erc20;

fn deploy_contract() -> (IErc20Dispatcher, ContractAddress) {
    let contract = declare("Erc20").unwrap().contract_class();

    let token_name: felt252 = 'Token Name';
    let token_symbol: felt252 = 'SYM';
    let token_decimals: u8 = 6;
    let initial_supply: felt252 = 100_000_000;
    let owner: ContractAddress = contract_address_const::<'owner'>();
    let constructor_calldata: Array<felt252> = array![
        token_name, token_symbol, token_decimals.into(), owner.into(), initial_supply.into(),
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

    let owner: ContractAddress = contract_address_const::<'owner'>();
    let balance_of_owner = dispatcher.balance_of(owner);
    assert(balance_of_owner == 100_000_000, 'Invalid initial balance')
}


#[test]
fn test_transfer() {
    let (dispatcher, token_address) = deploy_contract();

    let sender: ContractAddress = contract_address_const::<'owner'>();
    let recipient: ContractAddress = contract_address_const::<'recipient'>();
    let amount = 100;

    let sender_balance_before = dispatcher.balance_of(sender);
    let recipient_balance_before = dispatcher.balance_of(recipient);

    start_cheat_caller_address(token_address, sender);
    dispatcher.transfer(recipient, amount);

    let sender_balance_after = dispatcher.balance_of(sender);
    let recipient_balance_after = dispatcher.balance_of(recipient);

    assert((sender_balance_before - amount) == sender_balance_after, 'Incorrect sender balance');
    assert(
        (recipient_balance_before + amount) == recipient_balance_after,
        'Incorrect recipient balance',
    );
}


#[test]
fn test_transfer_event() {
    let (dispatcher, token_address) = deploy_contract();

    let sender: ContractAddress = contract_address_const::<'owner'>();
    let recipient: ContractAddress = contract_address_const::<'recipient'>();
    let amount = 100;

    let mut spy = spy_events();

    start_cheat_caller_address(token_address, sender);
    dispatcher.transfer(recipient, amount);

    spy
        .assert_emitted(
            @array![
                (
                    token_address,
                    Erc20::Event::Transfer(
                        Erc20::Transfer { from: sender, to: recipient, value: amount },
                    ),
                ),
            ],
        );
}
