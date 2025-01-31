#[starknet::contract]
pub mod MockMerkleTreeWithHistory {
    use contracts::merkle_tree::merkle_tree::MerkleTreeWithHistoryComponent;

    component!(
        path: MerkleTreeWithHistoryComponent,
        storage: merkle_tree,
        event: MerkleTreeWithHistoryEvent,
    );

    #[storage]
    struct Storage {
        #[substorage(v0)]
        merkle_tree: MerkleTreeWithHistoryComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        MerkleTreeWithHistoryEvent: MerkleTreeWithHistoryComponent::Event,
    }

    #[abi(embed_v0)]
    impl MerkleTreeWithHistory =
        MerkleTreeWithHistoryComponent::MerkleTreeWithHistory<ContractState>;
}
