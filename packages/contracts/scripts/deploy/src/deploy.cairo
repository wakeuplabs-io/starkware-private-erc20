use sncast_std::{
    declare, deploy, DeclareResultTrait, get_nonce, FeeSettings, EthFeeSettings
};
use starknet::ContractAddress;

fn main() {
    let max_fee = 999999999999999;
    let salt = 0x3;
    let name: felt252 = 'Name';
    let symbol: felt252 = 'Symbol';
    let decimals: u8 = 6;
    let levels: usize = 12;
    let mint_commitment: felt252 = 0;
    let mint_amount_enc: felt252 = 0;
    let verifier_address: ContractAddress = 0x07e867f1fa6da2108dd2b3d534f1fbec411c5ec9504eb3baa1e49c7a0bef5ab5.try_into().unwrap();

    let declare_result =  match declare(
        "Privado",
        FeeSettings::Eth(EthFeeSettings { max_fee: Option::None }),
        Option::Some(get_nonce('latest'))
    ) {
        Result::Ok(result) => result,
        Result::Err(e) => panic!("Error declaring contract: {:?}", e),
    };
        
    let deploy_result = match deploy(
        *declare_result.class_hash(),
        array![
            name,
            symbol,
            decimals.into(),
            levels.into(),
            mint_commitment,
            mint_amount_enc,
            verifier_address.into()
        ],
        Option::Some(salt),
        true,
        FeeSettings::Eth(EthFeeSettings { max_fee: Option::Some(max_fee) }),
        Option::Some(get_nonce('pending'))
    ){
        Result::Ok(result) => result,
        Result::Err(e) => panic!("Error deploying contract: {:?}", e),
    };

    assert(deploy_result.transaction_hash != 0, deploy_result.transaction_hash);
}
