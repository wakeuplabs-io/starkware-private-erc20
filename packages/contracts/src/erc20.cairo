use starknet::ContractAddress;

#[starknet::interface]
pub trait IErc20<TContractState> {
    fn name(self: @TContractState) -> felt252;

    fn symbol(self: @TContractState) -> felt252;

    fn decimals(self: @TContractState) -> u8;

    fn total_supply(self: @TContractState) -> u256;

    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;

    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256);

    fn allowance(
        self: @TContractState, owner: ContractAddress, spender: ContractAddress,
    ) -> u256;

    fn transfer_from(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
    ) -> bool;

    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256);
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
        total_supply: u256,
        balances: Map<ContractAddress, u256>,
        allowances: Map<ContractAddress, Map<ContractAddress, u256>>,
    }

    // events

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }
    #[derive(Drop, starknet::Event)]
    pub struct Transfer {
        pub from: ContractAddress,
        pub to: ContractAddress,
        pub value: u256,
    }
    #[derive(Drop, starknet::Event)]
    pub struct Approval {
        pub owner: ContractAddress,
        pub spender: ContractAddress,
        pub value: u256,
    }

    // errors

    pub mod Errors {
        pub const APPROVE_FROM_ZERO: felt252 = 'ERC20: approve from 0';
        pub const APPROVE_TO_ZERO: felt252 = 'ERC20: approve to 0';
        pub const TRANSFER_FROM_ZERO: felt252 = 'ERC20: transfer from 0';
        pub const TRANSFER_TO_ZERO: felt252 = 'ERC20: transfer to 0';
        pub const BURN_FROM_ZERO: felt252 = 'ERC20: burn from 0';
        pub const MINT_TO_ZERO: felt252 = 'ERC20: mint to 0';
        pub const INSUFFICIENT_BALANCE: felt252 = 'ERC20: insufficient balance';
        pub const INSUFFICIENT_ALLOWANCE: felt252 = 'ERC20: insufficient allowance';
        pub const EXPIRED_PERMIT_SIGNATURE: felt252 = 'ERC20: expired permit signature';
        pub const INVALID_PERMIT_SIGNATURE: felt252 = 'ERC20: invalid permit signature';
    }

    // constructor 

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        decimals: u8,
        recipient: ContractAddress
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);

        // TODO: make total_supply supply dynamic. Openzepeling uses mint function. Issue is in converting felt252 array to u256
        self.balances.entry(recipient).write(100_000_000);
        self.total_supply.write(100_000_000);

        // assert!(initial_supply != 0, "ERC20: Initial supply is 0");
        // self.total_supply.write(initial_supply);

        // assert!(!recipient.is_zero(), "ERC20: mint to the 0 address");
        // self.balances.entry(recipient).write(initial_supply);
    }

    // implementation

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

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.entry(account).read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let sender = get_caller_address();

            assert(!sender.is_zero(), Errors::TRANSFER_FROM_ZERO);
            assert(!recipient.is_zero(), Errors::TRANSFER_TO_ZERO);
            self.balances.entry(sender).write(self.balances.entry(sender).read() - amount);
            self.balances.entry(recipient).write(self.balances.entry(recipient).read() + amount);
            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress,
        ) -> u256 {
            self.allowances.entry(owner).entry(spender).read()
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        )-> bool {
            let caller = get_caller_address();

            // verify enough allowance
            let current_allowance = self.allowances.entry(sender).entry(caller).read();
            assert(current_allowance >= amount, Errors::INSUFFICIENT_ALLOWANCE);
            self.allowances.entry(sender).entry(caller).write(current_allowance - amount);

            // transfer
            assert(!sender.is_zero(), Errors::TRANSFER_FROM_ZERO);
            assert(!recipient.is_zero(), Errors::TRANSFER_TO_ZERO);
            self.balances.entry(sender).write(self.balances.entry(sender).read() - amount);
            self.balances.entry(recipient).write(self.balances.entry(recipient).read() + amount);
            self.emit(Transfer { from: sender, to: recipient, value: amount });

            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            assert(!spender.is_zero(), Errors::APPROVE_FROM_ZERO);

            self.allowances.entry(caller).entry(spender).write(amount);
            self.emit(Approval { owner: caller, spender, value: amount });
        }
    }
}
