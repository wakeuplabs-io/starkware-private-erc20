// TODO: remove limit on transactions

#[starknet::interface]
pub trait IMerkleTreeWithHistory<TContractState> {
    fn initialize(ref self: TContractState, levels: usize);
    fn get_last_root(self: @TContractState) -> felt252;
    fn is_known_root(self: @TContractState, root: felt252) -> bool;
    fn insert(ref self: TContractState, leaf: felt252) -> usize;
}

#[starknet::component]
pub mod MerkleTreeWithHistoryComponent {
    use alexandria_math::pow;
    use core::num::traits::Zero;
    use crate::merkle_tree::hashes::PoseidonCHasher;
    use crate::merkle_tree::constants::{ROOT_HISTORY_SIZE, ZERO_VALUE};
    use core::starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };

    // storage ====================================================================

    #[storage]
    pub struct Storage {
        filled_subtrees: Map<usize, felt252>,
        roots: Map<usize, felt252>,
        current_root_index: usize,
        next_index: usize,
        levels: usize,
    }

    // errors ======================================================================

    pub mod Errors {
        pub const MT_FULL: felt252 = 'MT: No more space';
        pub const MT_MAX_LEVELS: felt252 = 'MT: Levels must be < 32';
        pub const MT_MIN_LEVELS: felt252 = 'MT: Levels must be > 0';
    }

    // interface implementation ====================================================

    #[embeddable_as(MerkleTreeWithHistory)]
    impl MerkleTreeWithHistoryImpl<
        TContractState, +HasComponent<TContractState>,
    > of super::IMerkleTreeWithHistory<ComponentState<TContractState>> {
        fn initialize(ref self: ComponentState<TContractState>, levels: usize) {
            assert(levels.is_non_zero(), Errors::MT_MIN_LEVELS);
            assert(levels < 32, Errors::MT_MAX_LEVELS);

            self.levels.write(levels);

            // initialize merkle tree with zeros
            for i in 0..levels {
                self.filled_subtrees.entry(i).write(self._zeros(i));
            };
            self.roots.entry(0).write(self._zeros(levels - 1))
        }

        fn get_last_root(self: @ComponentState<TContractState>) -> felt252 {
            self.roots.entry(self.current_root_index.read()).read()
        }

        fn is_known_root(self: @ComponentState<TContractState>, root: felt252) -> bool {
            if (root.is_zero()) {
                return false;
            }

            let current_root_index = self.current_root_index.read();
            let mut i = current_root_index;

            let mut res = false;
            loop {
                if root == self.roots.entry(i).read() {
                    res = true;
                    break;
                }

                if i == 0 {
                    i = ROOT_HISTORY_SIZE;
                } else {
                    i = i - 1;
                }

                if i == current_root_index {
                    break;
                }
            };

            return res;
        }

        fn insert(ref self: ComponentState<TContractState>, leaf: felt252) -> usize {
            let next_index = self.next_index.read();
            let levels = self.levels.read();
            assert(next_index != pow(2, self.levels.read()) - 1, Errors::MT_FULL);

            let mut current_index = next_index;
            let mut current_level_hash = leaf;
            let mut left: felt252 = 0;
            let mut right: felt252 = 0;

            for i in 0..(levels - 1) {
                if current_index % 2 == 0 {
                    left = current_level_hash;
                    right = self._zeros(i);
                    self.filled_subtrees.entry(i).write(current_level_hash);
                } else {
                    left = self.filled_subtrees.entry(i).read();
                    right = current_level_hash;
                }

                current_level_hash = PoseidonCHasher::commutative_hash(left, right);
                current_index = current_index / 2;
            };

            let new_root_index = (self.current_root_index.read() + 1) % ROOT_HISTORY_SIZE;
            self.current_root_index.write(new_root_index);
            self.roots.entry(new_root_index).write(current_level_hash);
            self.next_index.write(next_index + 1);

            self.next_index.read()
        }
    }

    // internal implementation ====================================================

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +HasComponent<TContractState>,
    > of InternalTrait<TContractState> {
        fn _zeros(self: @ComponentState<TContractState>, i: usize) -> felt252 {
            if i == 0 {
                return ZERO_VALUE;
            } else {
                return PoseidonCHasher::commutative_hash(self._zeros(i - 1), self._zeros(i - 1));
            }
        }
    }
}
