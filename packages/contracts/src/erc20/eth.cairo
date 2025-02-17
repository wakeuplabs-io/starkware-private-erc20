#[starknet::interface]
pub trait IERC20<TContractState> {
    fn transfer_from(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256
    ) -> bool;
}

#[starknet::contract]
pub mod Erc20TokenMock {
    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl Erc20TokenMockImpl of super::IERC20<ContractState> {
        fn transfer_from(
            ref self: TContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            true
        }
    }
}
