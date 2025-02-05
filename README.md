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

# class_hash: 0x036baea6f8be3f8bd48e7e0976ca444132e37169b4fdf07b9c5faf4e575fb733
# transaction_hash: 0x02e86c45537ef0a2cb231c8053512255c4f2fae001c4daee40c89d5ce296ddd5

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x036baea6f8be3f8bd48e7e0976ca444132e37169b4fdf07b9c5faf4e575fb733
# transaction: https://sepolia.starkscan.co/tx/0x02e86c45537ef0a2cb231c8053512255c4f2fae001c4daee40c89d5ce296ddd5


just contracts-deploy-privado 0x036baea6f8be3f8bd48e7e0976ca444132e37169b4fdf07b9c5faf4e575fb733

# contract_address: 0x000029f4430cc63c28456d6c5b54029d00338e4c4ec7c873aa1dc1bc3fb38d55
# transaction_hash: 0x019d8743cddcf185e877885e717301f843b7c3573d7851a6fe6fd7602e2c4a67

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x000029f4430cc63c28456d6c5b54029d00338e4c4ec7c873aa1dc1bc3fb38d55
# transaction: https://sepolia.starkscan.co/tx/0x019d8743cddcf185e877885e717301f843b7c3573d7851a6fe6fd7602e2c4a67
```

## Circuits deployment

Generate the cairo contracts with:

```
circuits-generate-verifier
```

Declare and deploy the contract with 

```
circuits-declare-verifier

# class_hash: 0x036baea6f8be3f8bd48e7e0976ca444132e37169b4fdf07b9c5faf4e575fb733
# transaction_hash: 0x02e86c45537ef0a2cb231c8053512255c4f2fae001c4daee40c89d5ce296ddd5

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x036baea6f8be3f8bd48e7e0976ca444132e37169b4fdf07b9c5faf4e575fb733
# transaction: https://sepolia.starkscan.co/tx/0x02e86c45537ef0a2cb231c8053512255c4f2fae001c4daee40c89d5ce296ddd5


circuits-deploy-verifier 0x036baea6f8be3f8bd48e7e0976ca444132e37169b4fdf07b9c5faf4e575fb733

# contract_address: 0x000029f4430cc63c28456d6c5b54029d00338e4c4ec7c873aa1dc1bc3fb38d55
# transaction_hash: 0x019d8743cddcf185e877885e717301f843b7c3573d7851a6fe6fd7602e2c4a67

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x000029f4430cc63c28456d6c5b54029d00338e4c4ec7c873aa1dc1bc3fb38d55
# transaction: https://sepolia.starkscan.co/tx/0x019d8743cddcf185e877885e717301f843b7c3573d7851a6fe6fd7602e2c4a67
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
