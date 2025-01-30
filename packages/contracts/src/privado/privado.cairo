use starknet::ContractAddress;

#[starknet::interface]
pub trait IPrivado<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn transfer(
        ref self: TContractState,
        root: felt252,
        nullifier_hash: felt252,
        sender_commitment: felt252,
        sender_change: felt252,
        receiver_commitment: felt252,
        amount: felt252,
    ) -> bool;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256,
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
}

#[starknet::contract]
pub mod Privado {
    use starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use core::starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };
    use crate::merkle_tree::{MerkleTreeWithHistoryComponent, IMerkleTreeWithHistory};

    component!(path: MerkleTreeWithHistoryComponent, storage: merkle_tree, event: MerkleTreeEvent);

    #[storage]
    struct Storage {
        pub name: felt252,
        pub symbol: felt252,
        pub decimals: u8,
        pub allowances: Map<ContractAddress, Map<ContractAddress, u256>>,
        pub nullified_notes: Map<felt252, bool>,
        #[substorage(v0)]
        pub merkle_tree: MerkleTreeWithHistoryComponent::Storage,
    }

    // events

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        NewNote: NewNote,
        Approval: Approval,
        MerkleTreeEvent: MerkleTreeWithHistoryComponent::Event,
    }
    #[derive(Drop, starknet::Event)]
    pub struct Approval {
        pub owner: ContractAddress,
        pub spender: ContractAddress,
        pub value: u256,
    }
    #[derive(Drop, starknet::Event)]
    pub struct NewNote {
        pub commitment: felt252,
        pub amount: felt252, // encrypted
        pub index: usize,
    }

    // errors

    pub mod Errors {
        pub const UNKNOWN_ROOT: felt252 = 'Cannot find your merkle root';
        pub const SPENT_NOTE: felt252 = 'Note already spent';
        pub const APPROVE_FROM_ZERO: felt252 = 'ERC20: approve from 0';
        pub const APPROVE_TO_ZERO: felt252 = 'ERC20: approve to 0';
        pub const TRANSFER_FROM_ZERO: felt252 = 'ERC20: transfer from 0';
        pub const TRANSFER_TO_ZERO: felt252 = 'ERC20: transfer to 0';
        pub const INSUFFICIENT_BALANCE: felt252 = 'ERC20: insufficient balance';
        pub const INSUFFICIENT_ALLOWANCE: felt252 = 'ERC20: insufficient allowance';
    }

    // constructor

    #[constructor]
    pub fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        decimals: u8,
        levels: usize,
        mint_commitment: felt252,
        mint_amount_enc: felt252 // enc
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);

        // initialize merkle_tree
        self.merkle_tree.initialize(levels);

        // mint initial note with all funds
        self._create_note(mint_commitment, mint_amount_enc);
    }

    // interface implementation

    #[abi(embed_v0)]
    impl PrivadoImpl of super::IPrivado<ContractState> {
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
            0
        }

        fn total_supply(self: @ContractState) -> u256 {
            0
        }

        fn transfer(
            ref self: ContractState,
            root: felt252,
            nullifier_hash: felt252,
            sender_commitment: felt252,
            sender_change: felt252, // enc
            receiver_commitment: felt252,
            amount: felt252 // enc
        ) -> bool {
            assert(self.merkle_tree.is_known_root(root), Errors::UNKNOWN_ROOT);
            assert(!self.nullified_notes.entry(nullifier_hash).read(), Errors::SPENT_NOTE);

            // TODO:
            // assert(verifier.verifyProof, "Invalid transfer proof");

            // spend the notes
            self.nullified_notes.entry(nullifier_hash).write(true);

            // create new notes for receiver and sender
            self._create_note(sender_commitment, sender_change);
            self._create_note(receiver_commitment, amount);

            true
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
        ) -> bool {
            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            true
        }
    }

    // internal implementation

    #[generate_trait]
    pub impl InternalImpl of InternalTrait {
        fn _create_note(ref self: ContractState, commitment: felt252, amount: felt252) {
            let index = self.merkle_tree.insert(commitment);
            self.emit(NewNote { commitment, amount, index });
        }
    }
}
