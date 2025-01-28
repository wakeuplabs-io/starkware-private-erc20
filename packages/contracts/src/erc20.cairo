
#[starknet::interface]
pub trait IErc20<TContractState> {
    fn name(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod Erc20 {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        name: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, name: felt252) {
        self.name.write(name);
    }

    #[abi(embed_v0)]
    impl Erc20Impl of super::IErc20<ContractState> {

        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }
    }
}
