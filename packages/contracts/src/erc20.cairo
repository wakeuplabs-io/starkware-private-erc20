use starknet::ContractAddress;

#[starknet::interface]
pub trait IErc20<TContractState> {
    fn name(self: @TContractState) -> felt252;

    fn symbol(self: @TContractState) -> felt252;

    fn decimals(self: @TContractState) -> u8;

    fn total_supply(self: @TContractState) -> felt252;

    fn balance_of(self: @TContractState, account: ContractAddress) -> felt252;
    
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: felt252);

    // transferFrom
    // approve
    // allowance
}

#[starknet::contract]
pub mod Erc20 {
    use super::IErc20;
use core::num::traits::Zero;
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use core::starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        balances: Map<ContractAddress, felt252>,
        total_supply: felt252,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Transfer {
        pub from: ContractAddress,
        pub to: ContractAddress,
        pub value: felt252,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        decimals: u8,
        recipient: ContractAddress,
        initial_supply: felt252,
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);
        
        assert!(initial_supply != 0, "ERC20: Initial supply is 0");
        self.total_supply.write(initial_supply);
        
        assert!(!recipient.is_zero(), "ERC20: mint to the 0 address");
        self.balances.entry(recipient).write(initial_supply);

    }

    #[abi(embed_v0)]
    impl Erc20Impl of super::IErc20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> felt252 {
            self.balances.entry(account).read()
        }

        fn total_supply(self: @ContractState) -> felt252 {
            self.total_supply.read()
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            let sender = get_caller_address();

            assert(!sender.is_zero(), 'ERC20: transfer from 0');
            assert(!recipient.is_zero(), 'ERC20: transfer to 0');
            self.balances.entry(sender).write(self.balances.entry(sender).read() - amount);
            self.balances.entry(recipient).write(self.balances.entry(recipient).read() + amount);
            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }
    }
}
