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

# class_hash: 0x034d2e883b3240eb5c2e343070cf02cbb703cc38dac0dd28b66584c9ea6ebd7c
# transaction_hash: 0x0528c208ffe8e642007be90dd2bbe8f117afe77b137a6eea6f3c3f0020071768

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x034d2e883b3240eb5c2e343070cf02cbb703cc38dac0dd28b66584c9ea6ebd7c
# transaction: https://sepolia.starkscan.co/tx/0x0528c208ffe8e642007be90dd2bbe8f117afe77b137a6eea6f3c3f0020071768

just contracts-deploy-privado 0x034d2e883b3240eb5c2e343070cf02cbb703cc38dac0dd28b66584c9ea6ebd7c

# contract_address: 0x00f192bee5297e94e09db9531368cc70ed9debe41adcc6d796ecd9d93c7097e4
# transaction_hash: 0x02f6a46276cb7fd03b8a1b2dfa9b2a5904d99118cee35639af77d447c6f61347

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x00f192bee5297e94e09db9531368cc70ed9debe41adcc6d796ecd9d93c7097e4
# transaction: https://sepolia.starkscan.co/tx/0x02f6a46276cb7fd03b8a1b2dfa9b2a5904d99118cee35639af77d447c6f61347
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
