// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;

// 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock.
// 0x05de08a903058f97d2a9d8576730ef602eee53f143ecc4affd2f9167d4b92651 sepolia verifier
pub const TRANSFER_VERIFIER_ADDRESS: felt252 =
    0x05de08a903058f97d2a9d8576730ef602eee53f143ecc4affd2f9167d4b92651;
pub const APPROVE_VERIFIER_ADDRESS: felt252 =
    0x03c14b798cb4ee3d0b045f3877eb1ade1e13929b32051e976947ef72b8344f09;
pub const TRANSFER_FROM_VERIFIER_ADDRESS: felt252 =
    0x03c14b798cb4ee3d0b045f3877eb1ade1e13929b32051e976947ef72b8344f09;

pub const MERKLE_TREE_INITIAL_ROOT: u256 =
    0x2014041a4a7a0ac1ba11adeec064fdf62d54fbfb0a2a6cb1be92163d8e1f349b; // should already include the first commitment
pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0x1c028244f99518875102dff733c34fdc80f9be59ef16ecd5befbe7f4e83960b,
        "xN15gk5bIQlJSo2N44h2v0ATGPDYcW4-zpJaKV0R0lLnT14Q5PdqXnBuDPcuVH82lHEijlx9cxcw2x5t3DmKomsM5z3YLKuNKqOqfnbIE1hNk0g5pyPaojfwG8EtxZP-UygaHw4lwM3Y3qLaRX5c6kOC1A"
    )
}
// testnet sepolia ========================================================================


