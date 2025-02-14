#[starknet::interface]
pub trait ITransferFromVerifierContract<ContractState> {
    fn verify_ultra_keccak_honk_proof(
        self: @ContractState, full_proof_with_hints: Span<felt252>,
    ) -> Option<Span<u256>>;
}


#[starknet::contract]
pub mod TransferFromVerifierMock {
    #[storage]
    struct Storage {}


    #[abi(embed_v0)]
    impl TransferFromVerifierMockImpl of super::ITransferFromVerifierContract<ContractState> {
        fn verify_ultra_keccak_honk_proof(
            self: @ContractState, full_proof_with_hints: Span<felt252>,
        ) -> Option<Span<u256>> {
            if full_proof_with_hints.len() == 8 {
                let mut arr: Array<u256> = ArrayTrait::new();
                arr.append((*full_proof_with_hints.at(0)).into());
                arr.append((*full_proof_with_hints.at(1)).into());
                arr.append((*full_proof_with_hints.at(2)).into());
                arr.append((*full_proof_with_hints.at(3)).into());
                arr.append((*full_proof_with_hints.at(4)).into());
                arr.append((*full_proof_with_hints.at(5)).into());
                arr.append((*full_proof_with_hints.at(6)).into());
                arr.append((*full_proof_with_hints.at(7)).into());

                Option::Some(arr.span())
            } else {
                Option::None
            }
        }
    }
}
