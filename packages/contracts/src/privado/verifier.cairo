#[starknet::interface]
pub trait ITransferVerifierContract<ContractState> {
    fn verify_ultra_keccak_honk_proof(
        self: @ContractState, full_proof_with_hints: Span<felt252>,
    ) -> Option<Span<u256>>;
}


#[starknet::contract]
pub mod TransferVerifierMock {
    use contracts::privado::constants::{
        PUBLIC_INPUTS_ROOT_INDEX, PUBLIC_INPUTS_NULLIFIER_HASH_INDEX,
    };

    #[storage]
    struct Storage {}


    #[abi(embed_v0)]
    impl TransferVerifierMockImpl of super::ITransferVerifierContract<ContractState> {
        fn verify_ultra_keccak_honk_proof(
            self: @ContractState, full_proof_with_hints: Span<felt252>,
        ) -> Option<Span<u256>> {
            if full_proof_with_hints.len() > 0 {
                let mut arr: Array<u256> = ArrayTrait::new();
                arr.append((*full_proof_with_hints.at(PUBLIC_INPUTS_ROOT_INDEX)).into());
                arr.append((*full_proof_with_hints.at(PUBLIC_INPUTS_NULLIFIER_HASH_INDEX)).into());

                Option::Some(arr.span())
            } else {
                Option::None
            }
        }
    }
}
