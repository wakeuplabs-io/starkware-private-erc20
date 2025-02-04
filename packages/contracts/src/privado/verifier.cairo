#[starknet::interface]
pub trait ITransferVerifierContract<ContractState> {
    fn verify_ultra_keccak_honk_proof(
        self: @ContractState, full_proof_with_hints: Span<felt252>,
    ) -> Option<Span<u256>>;
}


#[starknet::contract]
pub mod TransferVerifierMock {

    #[storage]
    struct Storage {}


    #[abi(embed_v0)]
    impl TransferVerifierMockImpl of super::ITransferVerifierContract<ContractState> {
        fn verify_ultra_keccak_honk_proof(
            self: @ContractState, full_proof_with_hints: Span<felt252>,
        ) -> Option<Span<u256>> {
            if full_proof_with_hints.len() == 5 {
                let mut arr: Array<u256> = ArrayTrait::new();
                arr.append((*full_proof_with_hints.at(0)).into());
                arr.append((*full_proof_with_hints.at(1)).into());
                arr.append((*full_proof_with_hints.at(2)).into());
                arr.append((*full_proof_with_hints.at(3)).into());
                arr.append((*full_proof_with_hints.at(4)).into());

                Option::Some(arr.span())
            } else {
                Option::None
            }
        }
    }
}
