# Private ERC20

## Overview

Design is inspired in privacy pools like [tornado nova](https://github.com/tornadocash/tornado-core/tree/master) and [zcash](https://github.com/zcash/orchard)

## Deployments setup

Create the deployer account

```bash
just contracts-deployer-account-create

# address: 0x0528604705c912b3a6debc3bb63370659b884fb370191c9c48ccb59a9b9f3e24
# max_fee: 117743078418
# message: Account successfully created. Prefund generated address with at least <max_fee> STRK tokens or an equivalent amount of ETH tokens. It is good to send more in the case of higher demand.
```

Prefund generated address with at least <max_fee> STRK tokens or an equivalent amount of ETH tokens and then run

```bash
just contracts-deployer-account-deploy
```

## Circuits deployment

First make sure to update DEPTH accordingly in your circuit. Then generate the cairo contracts with:

```bash
just circuits-generate-verifier

(cd packages/circuits/transfer && nargo build)
(cd packages/circuits/transfer && bb write_vk_ultra_keccak_honk -b target/transfer.json -o target/vk.bin)
Finalized circuit size: 1035
Log dyadic circuit size: 11
(cd packages/circuits/transfer && garaga gen --system ultra_keccak_honk --vk target/vk.bin --project-name contracts)
⠧ Generating Smart Contract project for ProofSystem.UltraKeccakHonk using vk.bin...
Done!
Smart Contract project created:
/Users/matzapata/git-work/starkware/starkware-private-erc20/packages/circuits/transfer/contracts/
├── .tools-versions
├── Scarb.lock
├── Scarb.toml
├── src/
│   ├── honk_verifier.cairo
│   ├── honk_verifier_circuits.cairo
│   ├── honk_verifier_constants.cairo
│   └── lib.cairo
└── target/
    ├── CACHEDIR.TAG
    └── release/
        ├── contracts.starknet_artifacts.json
        ├── contracts_UltraKeccakHonkVerifier.compiled_contract_class.json
        └── contracts_UltraKeccakHonkVerifier.contract_class.json
You can now test the main endpoint of the verifier using a proof and `garaga calldata` command.
```

Declare and deploy the contract with 

```bash
just circuits-declare-verifier

# class_hash: 0x07e3ff93fe0b912ff4b5deb7eb214abebcd4080106ef9f17d2be8700adffe96d
# transaction_hash: 0x060920be73003bae3bd3a339c43c172eb3f0b6612fd19ffb02c456d1fca751d7

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x07e3ff93fe0b912ff4b5deb7eb214abebcd4080106ef9f17d2be8700adffe96d
# transaction: https://sepolia.starkscan.co/tx/0x060920be73003bae3bd3a339c43c172eb3f0b6612fd19ffb02c456d1fca751d7

just circuits-deploy-verifier 0x07e3ff93fe0b912ff4b5deb7eb214abebcd4080106ef9f17d2be8700adffe96d

# contract_address: 0x0633b15d7dca420570bdff9f4444e1e25e3d7db287e453b407ea9c5c9d9ea33c
# transaction_hash: 0x06706bf32c0ce7473b73f2fbd072b454cc1196bdfc364ca87d789fd2a1db9440

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x0633b15d7dca420570bdff9f4444e1e25e3d7db287e453b407ea9c5c9d9ea33c
# transaction: https://sepolia.starkscan.co/tx/0x06706bf32c0ce7473b73f2fbd072b454cc1196bdfc364ca87d789fd2a1db9440
```

## Contracts deployment

Deployment with just command (Same for verifier if needed). First go to `src/privado/constants` and update properly.

```bash
just contracts-declare-privado

# class_hash: 0x00942929f24f118c1cbee2d7d4971867702360b746cf48700f50c54a42518bcd
# transaction_hash: 0x0640f7ba45ba257f59c08e7a60fbb860b5e7be504fd437ea00759c95192728a0

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x00942929f24f118c1cbee2d7d4971867702360b746cf48700f50c54a42518bcd
# transaction: https://sepolia.starkscan.co/tx/0x0640f7ba45ba257f59c08e7a60fbb860b5e7be504fd437ea00759c95192728a0

just contracts-deploy-privado 0x00942929f24f118c1cbee2d7d4971867702360b746cf48700f50c54a42518bcd

# contract_address: 0x046549bba3b8fa8aec9119f2ded1be234ac02696d75e2911cf65f4cedf8e32dd
# transaction_hash: 0x00d4178f23e3f50efa3d6be86b3a9d430c80f1f965eb5115f7dc2f1b7703ca3b

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x046549bba3b8fa8aec9119f2ded1be234ac02696d75e2911cf65f4cedf8e32dd
# transaction: https://sepolia.starkscan.co/tx/0x00d4178f23e3f50efa3d6be86b3a9d430c80f1f965eb5115f7dc2f1b7703ca3b
```


## Infra deployment

Create `.env` from `.env.example`

Compile circuits if not already compiled and take it to `api/circuits/transfer`

```
circuits/
   transfer/
      src/
         ...
         main.noir
      target/
         transfer.json
         vk.bin
      Nargo.toml
```

Deploy to aws with:

`npx sst deploy --stage staging`
