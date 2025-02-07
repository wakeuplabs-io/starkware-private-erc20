// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;

// 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock.
// 0x013084bdd0cd0911728a391da9d705a9b5e8abea9efad557d8f78ae4e9f5a08e sepolia verifier
pub const TRANSFER_VERIFIER_ADDRESS: felt252 =
    0x03c14b798cb4ee3d0b045f3877eb1ade1e13929b32051e976947ef72b8344f09;
pub const APPROVE_VERIFIER_ADDRESS: felt252 =
    0x03c14b798cb4ee3d0b045f3877eb1ade1e13929b32051e976947ef72b8344f09;

// const privateKey = BigInt("0x2efe4d50e62d08f1335a7d8b6e8cb0a1b92d68e9bc34fcab1f547b2588d36ff1")
// const publicKey = BigInt("0x9fe40de6a38adf7cb7ed7afbd20a65d068682ab1090fd6274a44b10be0cfad10");
// const address = BigInt("0xf4280fa36dd274233822111013be2d770e02332ac2766ae093aa25ee33a2d31")

pub const MERKLE_TREE_INITIAL_ROOT: u256 =
    0x2f3263cd8488a893cc8d2b48d874723b599027e91fa355ed050bf23d49020310; // should already include the first commitment
pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0x1c19b4e2cde7662f125ca488852bf75cd26049bb4027c19847f04b8d9abe747b,
        "Bp_RXfUSztR04BFmuvvZGUKZyiKPRoAmNWbMJnWlQWeCBBHYaN89O7foXaG4rxGR6maX6PLsNEjYgqf-0liDl6FRlx_DkAbX-lsvBBE1k1p3RVhVBrRRnZ4lrel65LZJL_POTwqs38iZnaxzRS-Z_9RPlQ",
    )
}
// testnet sepolia ========================================================================


