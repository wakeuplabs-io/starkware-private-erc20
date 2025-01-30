use starknet::ContractAddress;

#[starknet::interface]
pub trait IPrivado<TContractState> {
    /// Erc20Metadata
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;

    /// Erc20
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn transfer(
        ref self: TContractState,
        root: felt252,
        nullifier_hash: felt252,
        sender_commitment: felt252,
        sender_amount_enc: felt252,
        receiver_commitment: felt252,
        receiver_amount_enc: felt252,
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

    //
    // Events
    //

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        NewNote: NewNote,
        Approval: Approval,
        MerkleTreeEvent: MerkleTreeWithHistoryComponent::Event,
    }

    /// Emitted when the allowance of a `spender` for an `owner` is set by a call
    /// to `approve`. `value` is the new allowance.
    #[derive(Drop, starknet::Event)]
    pub struct Approval {
        pub owner: ContractAddress,
        pub spender: ContractAddress,
        pub value: u256,
    }

    /// Emitted when a transfer happens, we'll create 2 entries, one for the sender as a utxo
    /// and one for the receiver.
    /// - `amount_enc` should be encrypted with the note owner public key
    /// - `commitment` is H(H(nullifier, secret), amount) where amount is plaintext and H(nullifier,
    ///    secret) the receiver address
    #[derive(Drop, starknet::Event)]
    pub struct NewNote {
        pub commitment: felt252,
        pub amount_enc: felt252,
        pub index: usize,
    }

    //
    // Errors
    //

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

    //
    // Constructor
    //

    #[constructor]
    pub fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        decimals: u8,
        levels: usize,
        mint_commitment: felt252,
        mint_amount_enc: felt252,
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);

        // initialize merkle_tree
        self.merkle_tree.initialize(levels);

        // mint initial note with all funds
        self._create_note(mint_commitment, mint_amount_enc);
    }

    //
    // External
    //

    #[abi(embed_v0)]
    impl PrivadoImpl of super::IPrivado<ContractState> {
        /// Returns the name of the token.
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        /// Returns the ticker symbol of the token, usually a shorter version of the name.
        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        /// Returns the number of decimals used to get its user representation.
        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        /// In our zk world, balances are hidden so this lacks meaning
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            0
        }

        /// In our zk world, balances are hidden so this lacks meaning
        fn total_supply(self: @ContractState) -> u256 {
            0
        }

        /// Moves `amount` tokens from the caller's token balance to `to`.
        /// It does so secretly without reveling amounts nor identities.
        /// It'll verify UTXO secretly through a zk proof and emit the corresponding events while
        /// nullifying the spent notes.
        ///
        /// Requirements:
        ///
        /// - `root` is the root that will be used to corroborate user commitment is in the tree
        /// - `nullifier_hash` is the hash of the nullifier used to build the commitment
        /// - `sender_commitment` is the commitment that will be used to create the change note
        /// - `sender_amount_enc` is the amount of the change note encrypted with the sender public
        ///    key 
        /// - `receiver_commitment` in the commitment that will be used to create the receiver
        ///    note 
        /// - `receiver_amount_enc` is the amount of the note encrypted with the receiver
        ///    public key
        ///
        /// Emits a `NewNote` event.
        fn transfer(
            ref self: ContractState,
            root: felt252,
            nullifier_hash: felt252,
            sender_commitment: felt252,
            sender_amount_enc: felt252,
            receiver_commitment: felt252,
            receiver_amount_enc: felt252,
        ) -> bool {
            assert(self.merkle_tree.is_known_root(root), Errors::UNKNOWN_ROOT);
            assert(!self.nullified_notes.entry(nullifier_hash).read(), Errors::SPENT_NOTE);

            // TODO:
            // assert(verifier.verifyProof, "Invalid transfer proof");

            // spend the notes
            self.nullified_notes.entry(nullifier_hash).write(true);

            // create new notes for receiver and sender
            self._create_note(sender_commitment, sender_amount_enc);
            self._create_note(receiver_commitment, receiver_amount_enc);

            true
        }

        /// Returns the remaining number of tokens that `spender` is
        /// allowed to spend on behalf of `owner` through `transfer_from`.
        /// This is zero by default.
        /// This value changes when `approve` or `transfer_from` are called.
        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress,
        ) -> u256 {
            self.allowances.entry(owner).entry(spender).read()
        }

        /// Moves `amount` tokens from the caller's token balance to `to`.
        ///
        /// Requirements:
        ///
        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) -> bool {
            true
        }

        /// Sets `amount` as the allowance of `spender` over the caller’s tokens.
        ///
        /// Requirements:
        ///
        /// - `spender` is not the zero address.
        ///
        /// Emits an `Approval` event.
        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            true
        }
    }

        
    //
    // Internal
    //

    #[generate_trait]
    pub impl InternalImpl of InternalTrait {
        /// Internal method that creates notes
        ///
        /// Requirements:
        ///
        /// - `commitment` is the commitment that will be created
        /// - `amount_enc` is amount encrypted with the receiver public key
        ///
        /// Emits a `NewNote` event.
        fn _create_note(ref self: ContractState, commitment: felt252, amount_enc: felt252) {
            let index = self.merkle_tree.insert(commitment);
            self.emit(NewNote { commitment, amount_enc, index });
        }
    }
}
