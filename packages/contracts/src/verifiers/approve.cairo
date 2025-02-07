#[starknet::interface]
pub trait IApproveVerifierContract<ContractState> {
    fn verify_ultra_keccak_honk_proof(
        self: @ContractState, full_proof_with_hints: Span<felt252>,
    ) -> Option<Span<u256>>;
}


#[starknet::contract]
pub mod ApproveVerifierMock {
    #[storage]
    struct Storage {}


    #[abi(embed_v0)]
    impl ApproveVerifierMockImpl of super::IApproveVerifierContract<ContractState> {
        fn verify_ultra_keccak_honk_proof(
            self: @ContractState, full_proof_with_hints: Span<felt252>,
        ) -> Option<Span<u256>> {
            if full_proof_with_hints.len() == 2 {
                let mut arr: Array<u256> = ArrayTrait::new();
                arr.append((*full_proof_with_hints.at(0)).into());
                arr.append((*full_proof_with_hints.at(1)).into());

                Option::Some(arr.span())
            } else {
                Option::None
            }
        }
    }
}
