use starknet::ContractAddress;

#[starknet::interface]
pub trait IPrivado<TContractState> {
    /// Returns the name of the token.
    fn name(self: @TContractState) -> felt252;

    /// Returns the ticker symbol of the token, usually a shorter version of the name.
    fn symbol(self: @TContractState) -> felt252;

    /// Returns the number of decimals used to get its user representation.
    fn decimals(self: @TContractState) -> u8;

    /// In our zk world, balances are hidden so this lacks meaning
    fn total_supply(self: @TContractState) -> u256;

    /// In our zk world, balances are hidden so this lacks meaning
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;

    /// Moves `amount` tokens from the caller's token balance to `to`.
    /// It does so secretly without reveling amounts nor identities.
    /// It'll verify UTXO secretly through a zk proof and emit the corresponding events while
    /// nullifying the spent notes.
    ///
    /// Requirements:
    ///
    /// - `proof` validates utxos, ownership and exposes public inputs later
    /// - `sender_enc_output` is the amount of the change note encrypted with the sender public
    ///    key
    /// - `receiver_enc_output` is the amount of the note encrypted with the receiver
    ///    public key
    ///
    /// Emits a `NewCommitment` event.
    fn transfer(
        ref self: TContractState,
        proof: Span<felt252>,
        sender_enc_output: ByteArray,
        receiver_enc_output: ByteArray,
    ) -> bool;

    /// Returns the remaining number of tokens that `spender` is
    /// allowed to spend on behalf of `owner` through `transfer_from`.
    /// This is zero by default.
    /// This value changes when `approve` or `transfer_from` are called.
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;

    /// Moves `amount` tokens from the caller's token balance to `to`.
    ///
    /// Requirements:
    ///
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256,
    ) -> bool;


    /// Sets `amount` as the allowance of `spender` over the caller’s tokens.
    ///
    /// Requirements:
    ///
    /// - `spender` is not the zero address.
    ///
    /// Emits an `Approval` event.
    fn approve(
        ref self: TContractState, proof: Span<felt252>, enc_outputs: Span<ByteArray>,
    ) -> bool;


    /// Reads current_root from contract
    fn current_root(self: @TContractState) -> u256;

    /// Reads current_root from contract
    fn current_commitment_index(self: @TContractState) -> u256;
}


#[starknet::contract]
pub mod Privado {
    use starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use core::starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };
    use contracts::verifiers::{
        ITransferVerifierContractDispatcherTrait, ITransferVerifierContractDispatcher,
        IApproveVerifierContractDispatcherTrait, IApproveVerifierContractDispatcher,
    };
    use contracts::privado::constants::{
        TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, MERKLE_TREE_INITIAL_ROOT,
        TRANSFER_VERIFIER_ADDRESS, APPROVE_VERIFIER_ADDRESS, GET_MINT_COMMITMENT,
    };
    use starknet::get_block_timestamp;

    //
    // Storage
    //

    #[storage]
    struct Storage {
        pub name: felt252,
        pub symbol: felt252,
        pub decimals: u8,
        // commitments tree
        pub current_root: u256,
        pub current_commitment_index: u256,
        pub nullified_notes: Map<u256, bool>,
        // allowances
        pub allowances: Map<u256, u256>,
        // verifier addresses
        pub transfer_verifier_address: ContractAddress,
        pub approve_verifier_address: ContractAddress,
    }

    //
    // Events
    //

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        NewCommitment: NewCommitment,
        NewNullifier: NewNullifier,
        Approval: Approval,
    }

    /// Emitted when a transfer happens, we'll create 2 entries, one for the sender as a utxo
    /// and one for the receiver.
    /// - `output_enc` should be encrypted with the note owner public key
    /// - `commitment` is H(H(nullifier, secret), amount) where amount is plaintext and H(nullifier,
    ///    secret) the receiver address
    #[derive(Drop, starknet::Event)]
    pub struct NewCommitment {
        pub commitment: u256,
        pub output_enc: ByteArray,
        pub index: u256,
    }

    /// Emitted when a a note is nullified
    /// - `nullifier_hash` hash of the nullifier used
    #[derive(Drop, starknet::Event)]
    pub struct NewNullifier {
        pub nullifier_hash: u256,
    }

    /// Emitted when a a note is nullified
    /// - `nullifier_hash` hash of the nullifier used
    #[derive(Drop, starknet::Event)]
    pub struct Approval {
        pub timestamp: u64,
        pub approve_hash: u256,
        pub relationship_hash: u256,
        pub output_enc: ByteArray,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const UNKNOWN_ROOT: felt252 = 'Cannot find your merkle root';
        pub const SPENT_NOTE: felt252 = 'Note already spent';
        pub const CORRUPTED_INPUTS: felt252 = 'Public inputs dont match';
        pub const APPROVE_FROM_ZERO: felt252 = 'ERC20: approve from 0';
        pub const APPROVE_TO_ZERO: felt252 = 'ERC20: approve to 0';
        pub const TRANSFER_FROM_ZERO: felt252 = 'ERC20: transfer from 0';
        pub const TRANSFER_TO_ZERO: felt252 = 'ERC20: transfer to 0';
        pub const INSUFFICIENT_BALANCE: felt252 = 'ERC20: insufficient balance';
        pub const INSUFFICIENT_ALLOWANCE: felt252 = 'ERC20: insufficient allowance';
    }

    //
    // Structs
    //

    #[derive(Drop)]
    pub struct TransferProofPublicInputs {
        root: u256,
        new_root: u256,
        nullifier_hash: u256,
        sender_commitment: u256,
        receiver_commitment: u256,
    }

    #[derive(Drop)]
    pub struct ApproveProofPublicInputs {
        approve_hash: u256,
        relationship_hash: u256,
    }

    //
    // Constructor
    //

    #[constructor]
    pub fn constructor(ref self: ContractState) {
        self.name.write(TOKEN_NAME);
        self.symbol.write(TOKEN_SYMBOL);
        self.decimals.write(TOKEN_DECIMALS);

        // set transfer verifier address
        self.transfer_verifier_address.write(TRANSFER_VERIFIER_ADDRESS.try_into().unwrap());
        self.approve_verifier_address.write(APPROVE_VERIFIER_ADDRESS.try_into().unwrap());

        // current root already includes initial mint
        self.current_root.write(MERKLE_TREE_INITIAL_ROOT);

        // mint initial note with all funds
        let (mint_commitment, mint_output_enc) = GET_MINT_COMMITMENT();
        self._create_note(mint_commitment, mint_output_enc);
        self._create_note(0, "0"); // fill the first subtree
    }

    //
    // External
    //

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
            proof: Span<felt252>,
            sender_enc_output: ByteArray,
            receiver_enc_output: ByteArray,
        ) -> bool {
            // verify proof and that public inputs match
            let public_inputs = self._verify_transfer_proof(proof);
            assert(public_inputs.root == self.current_root.read(), Errors::UNKNOWN_ROOT);
            assert(
                !self.nullified_notes.entry(public_inputs.nullifier_hash).read(),
                Errors::SPENT_NOTE,
            );

            // assign new_root
            self.current_root.write(public_inputs.new_root);

            // spend the notes
            self._spend_note(public_inputs.nullifier_hash);

            // create new notes for receiver and sender
            self._create_note(public_inputs.sender_commitment, sender_enc_output);
            self._create_note(public_inputs.receiver_commitment, receiver_enc_output);

            true
        }

        fn approve(
            ref self: ContractState, proof: Span<felt252>, enc_outputs: Span<ByteArray>,
        ) -> bool {
            let public_inputs = self._verify_approve_proof(proof);

            // store new approve hash overwriting the previous one
            self
                .allowances
                .entry(public_inputs.relationship_hash)
                .write(public_inputs.approve_hash);

            // emit approval event for each encryption provided
            for output_enc in enc_outputs {
                self
                    .emit(
                        Approval {
                            relationship_hash: public_inputs.relationship_hash,
                            approve_hash: public_inputs.approve_hash,
                            timestamp: get_block_timestamp(),
                            output_enc: output_enc.clone(),
                        },
                    )
            };

            true
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress,
        ) -> u256 {
            0
        }


        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) -> bool {
            true
        }


        fn current_root(self: @ContractState) -> u256 {
            self.current_root.read()
        }

        fn current_commitment_index(self: @ContractState) -> u256 {
            self.current_commitment_index.read()
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
        /// - `output_enc` is amount encrypted with the receiver public key
        ///
        /// Emits a `NewCommitment` event.
        fn _create_note(ref self: ContractState, commitment: u256, output_enc: ByteArray) {
            let current_index = self.current_commitment_index.read();
            self
                .emit(
                    NewCommitment {
                        commitment, output_enc: output_enc.clone(), index: current_index,
                    },
                );
            self.current_commitment_index.write(current_index + 1);
        }

        /// Internal method that spends notes
        ///
        /// Requirements:
        ///
        /// - `nullifier_hash` is the commitment that will be created
        ///
        /// Emits a `NewNullifier` event.
        fn _spend_note(ref self: ContractState, nullifier_hash: u256) {
            self.nullified_notes.entry(nullifier_hash).write(true);
            self.emit(NewNullifier { nullifier_hash });
        }


        /// Internal method that verifies proof and returns formatted public inputs
        fn _verify_transfer_proof(
            ref self: ContractState, proof: Span<felt252>,
        ) -> TransferProofPublicInputs {
            let verifier = ITransferVerifierContractDispatcher {
                contract_address: self.transfer_verifier_address.read(),
            };
            let public_inputs = verifier.verify_ultra_keccak_honk_proof(proof).unwrap();

            TransferProofPublicInputs {
                root: (*public_inputs.at(0)),
                nullifier_hash: (*public_inputs.at(1)),
                receiver_commitment: (*public_inputs.at(2)),
                sender_commitment: (*public_inputs.at(3)),
                new_root: (*public_inputs.at(4)),
            }
        }

        /// Internal method that verifies approve proof and returns formatted public inputs
        fn _verify_approve_proof(
            ref self: ContractState, proof: Span<felt252>,
        ) -> ApproveProofPublicInputs {
            let verifier = IApproveVerifierContractDispatcher {
                contract_address: self.approve_verifier_address.read(),
            };
            let public_inputs = verifier.verify_ultra_keccak_honk_proof(proof).unwrap();

            ApproveProofPublicInputs {
                approve_hash: (*public_inputs.at(0)), relationship_hash: (*public_inputs.at(1)),
            }
        }
    }
}

