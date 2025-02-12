// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;

// 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock.
// 0x002cb91a49726604fb8cd4c2e82b860f845fb622ad63325cbae07b41a713f872 sepolia verifier
pub const TRANSFER_VERIFIER_ADDRESS: felt252 = 0x002cb91a49726604fb8cd4c2e82b860f845fb622ad63325cbae07b41a713f872;

// 0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371 sepolia
pub const APPROVE_VERIFIER_ADDRESS: felt252 = 0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371;

// 0x068847e9c8781b4cacbbce22a267b152b51cc4f5c56d1bb1a361fe66065cdffb sepolia
pub const TRANSFER_FROM_VERIFIER_ADDRESS: felt252 = 0x068847e9c8781b4cacbbce22a267b152b51cc4f5c56d1bb1a361fe66065cdffb;

// should already include the first commitment
pub const MERKLE_TREE_INITIAL_ROOT: u256 = 0x15d5bbef432aa62ac897328947dba4035f3602ee8259cb73eb11f44cfd85ab0c; 
pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0x1c028244f99518875102dff733c34fdc80f9be59ef16ecd5befbe7f4e83960b,
        "xN15gk5bIQlJSo2N44h2v0ATGPDYcW4-zpJaKV0R0lLnT14Q5PdqXnBuDPcuVH82lHEijlx9cxcw2x5t3DmKomsM5z3YLKuNKqOqfnbIE1hNk0g5pyPaojfwG8EtxZP-UygaHw4lwM3Y3qLaRX5c6kOC1A"
    )
}
// testnet sepolia ========================================================================


