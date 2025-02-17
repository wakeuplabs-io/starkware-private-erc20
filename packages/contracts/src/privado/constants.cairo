// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Enigma';
pub const TOKEN_SYMBOL: felt252 = 'ENG';
pub const TOKEN_DECIMALS: u8 = 6;

// 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock.
// 0x024c512b2b7649ce7fb4ecc26e161312a5fb07b4253bcf0fa2dd250a430cd467 sepolia verifier
pub const TRANSFER_VERIFIER_ADDRESS: felt252 = 0x024c512b2b7649ce7fb4ecc26e161312a5fb07b4253bcf0fa2dd250a430cd467;

// 0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371 sepolia
pub const APPROVE_VERIFIER_ADDRESS: felt252 = 0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371;

// 0x0086fe3a1c7cab01a7551b4ce095fae9bc5a85ccefb34ce90bea444e281c3949 sepolia
pub const TRANSFER_FROM_VERIFIER_ADDRESS: felt252 = 0x0086fe3a1c7cab01a7551b4ce095fae9bc5a85ccefb34ce90bea444e281c3949;

// 0x033c2588403405bdfbf08c0051e7fba2e9ce5cfc937c9d071455a6fe5f2f8da1 sepolia
pub const DEPOSIT_VERIFIER_ADDRESS: felt252 = 0x033c2588403405bdfbf08c0051e7fba2e9ce5cfc937c9d071455a6fe5f2f8da1;

// 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
pub const ETH_ERC20_TOKEN: felt252 = 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;

// should already include the first commitment
pub const MERKLE_TREE_INITIAL_ROOT: u256 = 0x27420ad1d0dfacbbe88a1c7b10ee82e1a0d60251199b207123dabfe0a6cb7880;
pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0x1b443d22e50edb360576a9dd3877842dc2e886be07fd7a36a3140e76120979d2,
        "Dpd2BlfQ-bcXKedX0HlwoALWyQn2YO5vql34L55Tb2_YfLRLCe83NjNffXTgqLs_qIvRCGpEvW9SlQX_RURFCwMvVVmKMC9AaFJNHY_1QR9LDyxsfjcdpVSlFX07MsvZka7UAEN-l1emfpstGDbG3XlFSt3wHw",
    )
}
// testnet sepolia ========================================================================


