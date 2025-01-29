use starknet::ContractAddress;
use starknet::{contract_address_const};
use snforge_std::{
    start_cheat_caller_address, spy_events, EventSpyAssertionsTrait, declare, ContractClassTrait,
    DeclareResultTrait,
};
use contracts::erc20::erc20::IErc20Dispatcher;
use contracts::erc20::erc20::IErc20DispatcherTrait;
use contracts::erc20::erc20::Erc20;
use contracts::erc20::constants::TOTAL_SUPPLY;

const TOKEN_NAME: felt252 = 'Token Name';
const TOKEN_SYMBOL: felt252 = 'SYM';
const TOKEN_DECIMALS: u8 = 6;

fn deploy_contract() -> (IErc20Dispatcher, ContractAddress) {
    let contract = declare("Erc20").unwrap().contract_class();

    let owner: ContractAddress = contract_address_const::<'owner'>();
    let constructor_calldata: Array<felt252> = array![
        TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS.into(), owner.into(),
    ];

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    let dispatcher = IErc20Dispatcher { contract_address };

    (dispatcher, contract_address)
}

#[test]
fn test_constructor() {
    let (dispatcher, _) = deploy_contract();

    let retrieved_name = dispatcher.name();
    assert(retrieved_name == TOKEN_NAME, 'Invalid name');

    let retrieved_symbol = dispatcher.symbol();
    assert(retrieved_symbol == TOKEN_SYMBOL, 'Invalid symbol');

    let retrieved_decimals = dispatcher.decimals();
    assert(retrieved_decimals == TOKEN_DECIMALS, 'Invalid decimals');

    let total_supply = dispatcher.total_supply();
    assert(total_supply == TOTAL_SUPPLY, 'Invalid total supply');

    let owner: ContractAddress = contract_address_const::<'owner'>();
    let balance_of_owner = dispatcher.balance_of(owner);
    assert(balance_of_owner == TOTAL_SUPPLY, 'Invalid initial balance')
}


// transfer tests

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
#[should_panic(expected: 'ERC20: transfer to 0')]
fn test_transfer_to_zero() {
    let (dispatcher, token_address) = deploy_contract();

    let sender: ContractAddress = contract_address_const::<'owner'>();
    let recipient: ContractAddress = contract_address_const::<0>();
    let amount = 100;

    start_cheat_caller_address(token_address, sender);
    dispatcher.transfer(recipient, amount);
}

#[test]
#[should_panic(expected: 'ERC20: insufficient balance')]
fn test_transfer_insufficient_balance() {
    let (dispatcher, token_address) = deploy_contract();

    let owner: ContractAddress = contract_address_const::<'owner'>();
    let recipient: ContractAddress = contract_address_const::<'recipient'>();

    start_cheat_caller_address(token_address, owner);
    dispatcher.transfer(recipient, TOTAL_SUPPLY * 2);
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

// approve tests

#[test]
fn test_approve() {
    let (dispatcher, token_address) = deploy_contract();

    let owner: ContractAddress = contract_address_const::<'owner'>();
    let spender: ContractAddress = contract_address_const::<'spender'>();
    let amount = 100;

    let mut spy = spy_events();

    start_cheat_caller_address(token_address, owner);
    dispatcher.approve(spender, amount);

    spy
        .assert_emitted(
            @array![
                (
                    token_address,
                    Erc20::Event::Approval(
                        Erc20::Approval { owner: owner, spender: spender, value: amount },
                    ),
                ),
            ],
        );

    let allowance = dispatcher.allowance(owner, spender);
    assert(allowance == amount, 'Incorrect allowance');
}


#[test]
#[should_panic(expected: 'ERC20: approve to 0')]
fn test_approve_to_zero() {
    let (dispatcher, token_address) = deploy_contract();

    let sender: ContractAddress = contract_address_const::<'owner'>();
    let spender: ContractAddress = contract_address_const::<0>();
    let amount = 100;

    start_cheat_caller_address(token_address, sender);
    dispatcher.approve(spender, amount);
}

// transfer from tests

#[test]
fn test_transfer_from() {
    let (dispatcher, token_address) = deploy_contract();

    let owner: ContractAddress = contract_address_const::<'owner'>();
    let spender: ContractAddress = contract_address_const::<'spender'>();
    let recipient: ContractAddress = contract_address_const::<'recipient'>();
    let amount = 100;

    start_cheat_caller_address(token_address, owner);
    dispatcher.approve(spender, amount);

    let sender_balance_before = dispatcher.balance_of(owner);
    let recipient_balance_before = dispatcher.balance_of(recipient);

    start_cheat_caller_address(token_address, spender);
    dispatcher.transfer_from(owner, recipient, amount);

    let sender_balance_after = dispatcher.balance_of(owner);
    let recipient_balance_after = dispatcher.balance_of(recipient);

    assert((sender_balance_before - amount) == sender_balance_after, 'Incorrect sender balance');
    assert(
        (recipient_balance_before + amount) == recipient_balance_after,
        'Incorrect recipient balance',
    );
}


#[test]
#[should_panic(expected: 'ERC20: insufficient allowance')]
fn test_transfer_from_insufficient_allowance() {
    let (dispatcher, token_address) = deploy_contract();

    let owner: ContractAddress = contract_address_const::<'owner'>();
    let spender: ContractAddress = contract_address_const::<'spender'>();
    let recipient: ContractAddress = contract_address_const::<'recipient'>();
    let amount = 100;

    start_cheat_caller_address(token_address, owner);
    dispatcher.approve(spender, amount - 10);

    start_cheat_caller_address(token_address, spender);
    dispatcher.transfer_from(owner, recipient, amount);
}


#[test]
#[should_panic(expected: 'ERC20: insufficient balance')]
fn test_transfer_from_insufficient_balance() {
    let (dispatcher, token_address) = deploy_contract();

    let owner: ContractAddress = contract_address_const::<'owner'>();
    let spender: ContractAddress = contract_address_const::<'spender'>();
    let recipient: ContractAddress = contract_address_const::<'recipient'>();

    start_cheat_caller_address(token_address, owner);
    dispatcher.approve(spender, TOTAL_SUPPLY * 4);

    start_cheat_caller_address(token_address, spender);
    dispatcher.transfer_from(owner, recipient, TOTAL_SUPPLY * 2);
}
