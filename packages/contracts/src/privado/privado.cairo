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
    /// nullifying the inputs.
    ///
    /// Requirements:
    ///
    /// - `proof` validates utxos, ownership and exposes public inputs later
    /// - `sender_enc_output` encrypted sender change commitment data
    /// - `receiver_enc_output` encrypted receiver change commitment data
    ///
    /// Emits a `NewCommitment` event.
    fn transfer(
        ref self: TContractState, proof: Span<felt252>, enc_notes_output: Span<ByteArray>,
    ) -> bool;

    /// Returns the allowance_hash for the relationship_hash
    fn allowance(self: @TContractState, relationship_hash: u256) -> u256;

    /// Moves `amount` tokens from the caller's token balance to `to`.
    fn transfer_from(
        ref self: TContractState,
        proof: Span<felt252>,
        enc_notes_output: Span<ByteArray>,
        enc_approval_output: Span<ByteArray>,
    ) -> bool;


    /// Sets `amount` as the allowance of `spender` over the caller’s tokens.
    fn approve(
        ref self: TContractState, proof: Span<felt252>, enc_approval_output: Span<ByteArray>,
    ) -> bool;

    /// Takes `eth` from user and mints note with equivalent in ENG
    fn deposit(
        ref self: TContractState, proof: Span<felt252>, receiver_enc_output: ByteArray,
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
        ITransferFromVerifierContractDispatcherTrait, ITransferFromVerifierContractDispatcher,
        IDepositVerifierContractDispatcherTrait, IDepositVerifierContractDispatcher,
    };
    use contracts::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use contracts::privado::constants::{
        TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, MERKLE_TREE_INITIAL_ROOT,
        TRANSFER_VERIFIER_ADDRESS, APPROVE_VERIFIER_ADDRESS, TRANSFER_FROM_VERIFIER_ADDRESS,
        DEPOSIT_VERIFIER_ADDRESS, ETH_ERC20_TOKEN, GET_MINT_COMMITMENT,
    };
    use starknet::{get_block_timestamp, get_caller_address, get_contract_address};

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
        pub nullifiers: Map<u256, bool>,
        // allowances
        pub allowances: Map<u256, u256>,
        // verifier addresses
        pub transfer_verifier_address: ContractAddress,
        pub approve_verifier_address: ContractAddress,
        pub transfer_from_verifier_address: ContractAddress,
        pub deposit_verifier_address: ContractAddress,
        pub eth_erc20_token: ContractAddress,
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
    #[derive(Drop, starknet::Event)]
    pub struct NewCommitment {
        pub commitment: u256,
        pub output_enc: ByteArray,
        pub index: u256,
    }

    /// Emitted when a a note is nullified
    #[derive(Drop, starknet::Event)]
    pub struct NewNullifier {
        pub nullifier: u256,
    }

    /// Emitted when user Approves external entity
    /// - allowance_relationship = hash of relationship so we can use as key and query
    #[derive(Drop, starknet::Event)]
    pub struct Approval {
        #[key]
        pub allowance_relationship: u256,
        pub timestamp: u64,
        pub allowance_hash: u256,
        pub output_enc_owner: ByteArray,
        pub output_enc_spender: ByteArray,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const UNKNOWN_ROOT: felt252 = 'Cannot find your merkle root';
        pub const SPENT_NOTE: felt252 = 'Note already spent';
        pub const UNKNOWN_ALLOWANCE_HASH: felt252 = 'Unknown allowance hash';
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
        in_commitment_root: u256,
        in_commitment_nullifier: u256,
        out_sender_commitment: u256,
        out_receiver_commitment: u256,
        out_root: u256,
    }

    #[derive(Drop)]
    pub struct TransferFromProofPublicInputs {
        in_commitment_root: u256,
        in_commitment_nullifier: u256,
        in_allowance_hash: u256,
        in_allowance_relationship: u256,
        out_allowance_hash: u256,
        out_receiver_commitment: u256,
        out_owner_commitment: u256,
        out_root: u256,
    }

    #[derive(Drop)]
    pub struct ApproveProofPublicInputs {
        out_allowance_hash: u256,
        out_allowance_relationship: u256,
    }

    #[derive(Drop)]
    pub struct DepositProofInputs {
        in_commitment_root: u256,
        in_public_amount: u256,
        out_receiver_commitment: u256,
        out_root: u256,
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
        self
            .transfer_from_verifier_address
            .write(TRANSFER_FROM_VERIFIER_ADDRESS.try_into().unwrap());
        self.deposit_verifier_address.write(DEPOSIT_VERIFIER_ADDRESS.try_into().unwrap());
        self.eth_erc20_token.write(ETH_ERC20_TOKEN.try_into().unwrap());

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
            ref self: ContractState, proof: Span<felt252>, enc_notes_output: Span<ByteArray>,
        ) -> bool {
            // verify proof and that public inputs match
            let public_inputs = self._verify_transfer_proof(proof);

            // assign new_root
            assert(
                public_inputs.in_commitment_root == self.current_root.read(), Errors::UNKNOWN_ROOT,
            );
            self.current_root.write(public_inputs.out_root);

            // spend the notes
            self._spend_note(public_inputs.in_commitment_nullifier);

            // create new notes for receiver and sender
            self._create_note(public_inputs.out_sender_commitment, enc_notes_output.at(0).clone());
            self
                ._create_note(
                    public_inputs.out_receiver_commitment, enc_notes_output.at(1).clone(),
                );

            true
        }

        fn approve(
            ref self: ContractState, proof: Span<felt252>, enc_approval_output: Span<ByteArray>,
        ) -> bool {
            let public_inputs = self._verify_approve_proof(proof);

            // store new approve hash overwriting the previous one
            self
                .allowances
                .entry(public_inputs.out_allowance_relationship)
                .write(public_inputs.out_allowance_hash);

            // emit approval event for each encryption provided
            self
                .emit(
                    Approval {
                        allowance_relationship: public_inputs.out_allowance_relationship,
                        allowance_hash: public_inputs.out_allowance_hash,
                        timestamp: get_block_timestamp(),
                        output_enc_owner: enc_approval_output.at(0).clone(),
                        output_enc_spender: enc_approval_output.at(1).clone(),
                    },
                );

            true
        }

        fn allowance(self: @ContractState, relationship_hash: u256) -> u256 {
            self.allowances.entry(relationship_hash).read()
        }


        fn transfer_from(
            ref self: ContractState,
            proof: Span<felt252>,
            enc_notes_output: Span<ByteArray>,
            enc_approval_output: Span<ByteArray>,
        ) -> bool {
            // verify proof and that public inputs match
            let public_inputs = self._verify_transfer_from_proof(proof);

            // verify matching old root and assign new_root
            assert(
                public_inputs.in_commitment_root == self.current_root.read(), Errors::UNKNOWN_ROOT,
            );
            self.current_root.write(public_inputs.out_root);

            // verify matching allowance hash and update it
            assert(
                public_inputs
                    .in_allowance_hash == self
                    .allowances
                    .entry(public_inputs.in_allowance_relationship)
                    .read(),
                Errors::UNKNOWN_ALLOWANCE_HASH,
            );
            self
                .allowances
                .entry(public_inputs.in_allowance_relationship)
                .write(public_inputs.out_allowance_hash);

            // spend the notes
            self._spend_note(public_inputs.in_commitment_nullifier);

            // create new notes for receiver and sender
            self._create_note(public_inputs.out_owner_commitment, enc_notes_output.at(0).clone());
            self
                ._create_note(
                    public_inputs.out_receiver_commitment, enc_notes_output.at(1).clone(),
                );

            // emit approval event with latest data
            self
                .emit(
                    Approval {
                        allowance_relationship: public_inputs.in_allowance_relationship,
                        allowance_hash: public_inputs.out_allowance_hash,
                        timestamp: get_block_timestamp(),
                        output_enc_owner: enc_approval_output.at(0).clone(),
                        output_enc_spender: enc_approval_output.at(1).clone(),
                    },
                );

            true
        }

        fn deposit(
            ref self: ContractState, proof: Span<felt252>, receiver_enc_output: ByteArray,
        ) -> bool {
            let public_inputs = self._verify_deposit_proof(proof);

            assert(
                public_inputs.in_commitment_root == self.current_root.read(), Errors::UNKNOWN_ROOT,
            );
            self.current_root.write(public_inputs.out_root);

            self._create_note(public_inputs.out_receiver_commitment, receiver_enc_output);
            self._create_note(0, "0");

            let eth_erc20_token = IERC20Dispatcher {
                contract_address: self.eth_erc20_token.read(),
            };
            eth_erc20_token
                .transfer_from(
                    get_caller_address(), get_contract_address(), public_inputs.in_public_amount,
                );

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
        /// - `output_enc` is the commitment data encrypted with owner public key
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

        /// Internal method that spends notes. First check it's not already spent, then spend it
        ///
        /// Requirements:
        ///
        /// - `nullifier`
        ///
        /// Emits a `NewNullifier` event.
        fn _spend_note(ref self: ContractState, nullifier: u256) {
            assert(self.nullifiers.entry(nullifier).read() == false, Errors::SPENT_NOTE);

            self.nullifiers.entry(nullifier).write(true);
            self.emit(NewNullifier { nullifier });
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
                in_commitment_root: (*public_inputs.at(0)),
                in_commitment_nullifier: (*public_inputs.at(1)),
                out_receiver_commitment: (*public_inputs.at(2)),
                out_sender_commitment: (*public_inputs.at(3)),
                out_root: (*public_inputs.at(4)),
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
                out_allowance_hash: (*public_inputs.at(0)),
                out_allowance_relationship: (*public_inputs.at(1)),
            }
        }

        /// Internal method that verifies approve proof and returns formatted public inputs
        fn _verify_transfer_from_proof(
            ref self: ContractState, proof: Span<felt252>,
        ) -> TransferFromProofPublicInputs {
            let verifier = ITransferFromVerifierContractDispatcher {
                contract_address: self.transfer_from_verifier_address.read(),
            };
            let public_inputs = verifier.verify_ultra_keccak_honk_proof(proof).unwrap();

            TransferFromProofPublicInputs {
                in_commitment_root: (*public_inputs.at(0)),
                in_commitment_nullifier: (*public_inputs.at(1)),
                in_allowance_hash: (*public_inputs.at(2)),
                in_allowance_relationship: (*public_inputs.at(3)),
                out_allowance_hash: (*public_inputs.at(4)),
                out_receiver_commitment: (*public_inputs.at(5)),
                out_owner_commitment: (*public_inputs.at(6)),
                out_root: (*public_inputs.at(7)),
            }
        }

        fn _verify_deposit_proof(
            ref self: ContractState, proof: Span<felt252>,
        ) -> DepositProofInputs {
            let verifier = IDepositVerifierContractDispatcher {
                contract_address: self.deposit_verifier_address.read(),
            };

            let public_inputs = verifier.verify_ultra_keccak_honk_proof(proof).unwrap();

            DepositProofInputs {
                in_commitment_root: (*public_inputs.at(0)),
                in_public_amount: (*public_inputs.at(1)),
                out_receiver_commitment: (*public_inputs.at(2)),
                out_root: (*public_inputs.at(3)),
            }
        }
    }
}

