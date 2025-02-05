
// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;
pub const MERKLE_TREE_INITIAL_ROOT: u256 = 0x14673c177b52999e9ba7c4e17f8854c48c01e0d860f2e1d82116194869c7b290;  // should already include the first commitment
pub const TRANSFER_VERIFIER_ADDRESS: felt252 = 0x03c14b798cb4ee3d0b045f3877eb1ade1e13929b32051e976947ef72b8344f09; // 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock. 0x013084bdd0cd0911728a391da9d705a9b5e8abea9efad557d8f78ae4e9f5a08e sepolia verifier

pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0x088d53700d1bf7247d7a9b65a7b3a9f2b42069f44b31622c673be62fae41150e,
        "NlXMQe0Yey/8V2Y1etNu9WFPqSBMtcRRBxm58Su4H9dCb2j/NxnpBj3pamUbt83DxxyCzHA=",
    )
}

// testnet sepolia ========================================================================
