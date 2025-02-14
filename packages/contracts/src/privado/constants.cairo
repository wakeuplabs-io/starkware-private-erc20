// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Enigma';
pub const TOKEN_SYMBOL: felt252 = 'ENG';
pub const TOKEN_DECIMALS: u8 = 6;

// 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock.
// 0x002cb91a49726604fb8cd4c2e82b860f845fb622ad63325cbae07b41a713f872 sepolia verifier
pub const TRANSFER_VERIFIER_ADDRESS: felt252 =
    0x002cb91a49726604fb8cd4c2e82b860f845fb622ad63325cbae07b41a713f872;

// 0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371 sepolia
pub const APPROVE_VERIFIER_ADDRESS: felt252 =
    0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371;

// 0x0086fe3a1c7cab01a7551b4ce095fae9bc5a85ccefb34ce90bea444e281c3949 sepolia
pub const TRANSFER_FROM_VERIFIER_ADDRESS: felt252 =
    0x0086fe3a1c7cab01a7551b4ce095fae9bc5a85ccefb34ce90bea444e281c3949;

// should already include the first commitment
pub const MERKLE_TREE_INITIAL_ROOT: u256 =
    0x27420ad1d0dfacbbe88a1c7b10ee82e1a0d60251199b207123dabfe0a6cb7880;
pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0x1b443d22e50edb360576a9dd3877842dc2e886be07fd7a36a3140e76120979d2,
        "Dpd2BlfQ-bcXKedX0HlwoALWyQn2YO5vql34L55Tb2_YfLRLCe83NjNffXTgqLs_qIvRCGpEvW9SlQX_RURFCwMvVVmKMC9AaFJNHY_1QR9LDyxsfjcdpVSlFX07MsvZka7UAEN-l1emfpstGDbG3XlFSt3wHw",
    )
}
// testnet sepolia ========================================================================


