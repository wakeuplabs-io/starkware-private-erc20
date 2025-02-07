// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;

// 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock. 0x05de08a903058f97d2a9d8576730ef602eee53f143ecc4affd2f9167d4b92651 sepolia verifier
pub const TRANSFER_VERIFIER_ADDRESS: felt252 = 0x05de08a903058f97d2a9d8576730ef602eee53f143ecc4affd2f9167d4b92651; 

pub const MERKLE_TREE_INITIAL_ROOT: u256 = 0x2014041a4a7a0ac1ba11adeec064fdf62d54fbfb0a2a6cb1be92163d8e1f349b;  // should already include the first commitment
pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0xD8BF9DAA6A48439A3EE467CBCD7084BF4A5CE590839E9C9F63DFC91BEFE614E,
        "wPmqd6w0l3nOdAPjLyy-nEUIGy-x_9R1zlxyyyqKlAO9eNkAEZK8nIm7Eko74rqTC74gYG7iwmYP2x-PJPbc0dNt3hKyU8SPYGHrASGzT7RDKtRaTK7pk8oJ8w3xSrSUUR3I4YsbfA4UnpC95gg",
    )
}
// testnet sepolia ========================================================================


