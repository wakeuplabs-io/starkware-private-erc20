
// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;

// 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock. 0x0633b15d7dca420570bdff9f4444e1e25e3d7db287e453b407ea9c5c9d9ea33c sepolia verifier
pub const TRANSFER_VERIFIER_ADDRESS: felt252 = 0x0633b15d7dca420570bdff9f4444e1e25e3d7db287e453b407ea9c5c9d9ea33c; 

// const privateKey = BigInt("0x2efe4d50e62d08f1335a7d8b6e8cb0a1b92d68e9bc34fcab1f547b2588d36ff1")
// const publicKey = BigInt("0x9fe40de6a38adf7cb7ed7afbd20a65d068682ab1090fd6274a44b10be0cfad10");
// const address = BigInt("0xf4280fa36dd274233822111013be2d770e02332ac2766ae093aa25ee33a2d31")

pub const MERKLE_TREE_INITIAL_ROOT: u256 = 0x1fd5b00bb3d7e979fad782f4f1309c0d649eafaabcad99d2bf976d90efc52ff9;  // should already include the first commitment
pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0xD8BF9DAA6A48439A3EE467CBCD7084BF4A5CE590839E9C9F63DFC91BEFE614E,
        "wPmqd6w0l3nOdAPjLyy-nEUIGy-x_9R1zlxyyyqKlAO9eNkAEZK8nIm7Eko74rqTC74gYG7iwmYP2x-PJPbc0dNt3hKyU8SPYGHrASGzT7RDKtRaTK7pk8oJ8w3xSrSUUR3I4YsbfA4UnpC95gg",
    )
}

// testnet sepolia ========================================================================
