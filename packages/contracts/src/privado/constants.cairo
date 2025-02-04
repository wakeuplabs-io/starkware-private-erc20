
// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;
pub const MERKLE_TREE_INITIAL_ROOT: u256 = 0x14673c177b52999e9ba7c4e17f8854c48c01e0d860f2e1d82116194869c7b290;  // should already include the first commitment
pub const TRANSFER_VERIFIER_ADDRESS: felt252 = 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66; // 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock

pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0x088d53700d1bf7247d7a9b65a7b3a9f2b42069f44b31622c673be62fae41150e,
        "NlXMQe0Yey/8V2Y1etNu9WFPqSBMtcRRBxm58Su4H9dCb2j/NxnpBj3pamUbt83DxxyCzHA=",
    )
}

// testnet sepolia ========================================================================
