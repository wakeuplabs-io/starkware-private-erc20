# Private ERC20

## Overview

Design is inspired in privacy pools like [tornado nova](https://github.com/tornadocash/tornado-core/tree/master) and [zcash](https://github.com/zcash/orchard)


## Contracts deployment

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

Deployment with just command (Same for verifier if needed). First go to `src/privado/constants` and update properly.

```bash
just contracts-declare-privado

# class_hash: 0x038f9ef5809a58b6a3ecc981cca9b6cdb0244405f34c7ea48267684d17534218
# transaction_hash: 0x077f8977e780fa6d79e8d925d9c06a1cbc4595939ec811f47b38a547e9e8306c

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x038f9ef5809a58b6a3ecc981cca9b6cdb0244405f34c7ea48267684d17534218
# transaction: https://sepolia.starkscan.co/tx/0x077f8977e780fa6d79e8d925d9c06a1cbc4595939ec811f47b38a547e9e8306c

just contracts-deploy-privado 0x038f9ef5809a58b6a3ecc981cca9b6cdb0244405f34c7ea48267684d17534218

# contract_address: 0x00aca5509ad2876b2711f399c07469b956f4ba2d82a56d40ac4ffbf7e9dfee35
# transaction_hash: 0x03c635db61f86ab3f9bc6fa84ccbc50b54cb962555223cc1314b956e26718d31

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x00aca5509ad2876b2711f399c07469b956f4ba2d82a56d40ac4ffbf7e9dfee35
# transaction: https://sepolia.starkscan.co/tx/0x03c635db61f86ab3f9bc6fa84ccbc50b54cb962555223cc1314b956e26718d31
```

## Circuits deployment

Generate the cairo contracts with:

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

# class_hash: 0x0350eef8835d0ae74dee85d66d83120a2b18d74b0cb0e8a8ca84ea740aa8284d
# transaction_hash: 0x05d3f6307d2bb7fedea9270e2b13b92adb4438d9342badc9616bf10dd36b5800

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x0350eef8835d0ae74dee85d66d83120a2b18d74b0cb0e8a8ca84ea740aa8284d
# transaction: https://sepolia.starkscan.co/tx/0x05d3f6307d2bb7fedea9270e2b13b92adb4438d9342badc9616bf10dd36b5800


just circuits-deploy-verifier 0x0350eef8835d0ae74dee85d66d83120a2b18d74b0cb0e8a8ca84ea740aa8284d

# contract_address: 0x03c14b798cb4ee3d0b045f3877eb1ade1e13929b32051e976947ef72b8344f09
# transaction_hash: 0x061bdea3398af9296330eae1d8792ab37d27cfd551dbc2945b03ed88c28426ab

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x03c14b798cb4ee3d0b045f3877eb1ade1e13929b32051e976947ef72b8344f09
# transaction: https://sepolia.starkscan.co/tx/0x061bdea3398af9296330eae1d8792ab37d27cfd551dbc2945b03ed88c28426ab
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
