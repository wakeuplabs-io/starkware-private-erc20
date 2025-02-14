// testnet sepolia ========================================================================

pub const TOKEN_NAME: felt252 = 'Privado';
pub const TOKEN_SYMBOL: felt252 = 'PRV';
pub const TOKEN_DECIMALS: u8 = 6;

// 0x018ec86664d941e659f64bdcbd53d06ab9034b1981a6e5b8181017194e702a66 sepolia mock.
// 0x002cb91a49726604fb8cd4c2e82b860f845fb622ad63325cbae07b41a713f872 sepolia verifier
pub const TRANSFER_VERIFIER_ADDRESS: felt252 = 0x002cb91a49726604fb8cd4c2e82b860f845fb622ad63325cbae07b41a713f872;

// 0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371 sepolia
pub const APPROVE_VERIFIER_ADDRESS: felt252 = 0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371;

// 0x0086fe3a1c7cab01a7551b4ce095fae9bc5a85ccefb34ce90bea444e281c3949 sepolia
pub const TRANSFER_FROM_VERIFIER_ADDRESS: felt252 = 0x0086fe3a1c7cab01a7551b4ce095fae9bc5a85ccefb34ce90bea444e281c3949;

// should already include the first commitment
pub const MERKLE_TREE_INITIAL_ROOT: u256 = 0x18f894cfb0d1b9d64ec494cd24e9b15e00e05d27efa450e072d9df7f79b9e81d; 
pub fn GET_MINT_COMMITMENT() -> (u256, ByteArray) {
    (
        0x394cd38e24759a46bc2331baf12f338e09243c6a24920e33f9b7a23ee3f5439,
        "7jSyIVmdtWWXxOoELJ6NozUEuxOmqBpaA2_TkwZDDyN2gehWqeQh7f3OufxyzW78nmCQ9QzmsCzZNV5ScsDRV541Pycn--ZTaxWk57lKH7XrG3DAyR5BwjAFA2DHE0pFOjGj61TI2Fd_zz_HhDylrmY17Q"
    )
}
// testnet sepolia ========================================================================


