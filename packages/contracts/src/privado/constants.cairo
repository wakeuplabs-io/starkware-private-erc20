
// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;

// 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock. 0x073a29b78d1aa45a9c3fab87f93d682134a6ffe1a010214a493c7edc16587143 sepolia verifier
pub const TRANSFER_VERIFIER_ADDRESS: felt252 = 0x073a29b78d1aa45a9c3fab87f93d682134a6ffe1a010214a493c7edc16587143; 

// MERKLE_TREE_INITIAL_ROOT should already include the mint commitment
pub const MERKLE_TREE_INITIAL_ROOT: u256 = 0x15d5bbef432aa62ac897328947dba4035f3602ee8259cb73eb11f44cfd85ab0c;  
pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0x1c028244f99518875102dff733c34fdc80f9be59ef16ecd5befbe7f4e83960b,
        "xN15gk5bIQlJSo2N44h2v0ATGPDYcW4-zpJaKV0R0lLnT14Q5PdqXnBuDPcuVH82lHEijlx9cxcw2x5t3DmKomsM5z3YLKuNKqOqfnbIE1hNk0g5pyPaojfwG8EtxZP-UygaHw4lwM3Y3qLaRX5c6kOC1A"
    )
}

// testnet sepolia ========================================================================
