
// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;
pub const MERKLE_TREE_LEVELS: usize = 12;
pub const PUBLIC_INPUTS_ROOT_INDEX: usize = 0;
pub const PUBLIC_INPUTS_NULLIFIER_HASH_INDEX: usize = 1;
pub const TRANSFER_VERIFIER_ADDRESS: felt252 =
    0x0537951480e082dfa91db5777d0d8509335dd2881e9d7135805a2efbdc42b88d;

pub fn GET_MINT_COMMITMENT() -> (felt252, ByteArray) {
    (
        0x052dd6501b49185427b51fd6d47db5b969cff1068d2a5e18f085a17cb7ff76eb,
        "Ztqi0r2d77xHEULIhpQ4KSJY0h6zUKjtnRAU7n7FWGVJMha6CnZ8Df4W/KocBKkFfo7Dfhu6",
    )
}

// testnet sepolia ========================================================================
