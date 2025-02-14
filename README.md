# Private ERC20

## Overview

Design is inspired in privacy pools like [tornado nova](https://github.com/tornadocash/tornado-nova/tree/b085ab398eaeefff98771f5dad893cb804d98e70) and [zcash](https://github.com/zcash/orchard)

## Definitions

### Note

A "note" represents ownership information over a certain amount of tokens. The hash of this information is called the commitment and is stored in the contract's Merkle tree. The user balance is the sum of these notes.

### Nullifier

The nullifier is a unique value derived from a note to prevent double-spending. It is significant because it can only be created by the owner and is unequivocally linked to a single note. This is achieved by using the hash of the note to prevent any attempt at double-spending.

### Keypairs

The user's wallet consists of an asymetric keypair build with sodium Curve25519. Certain relevant information required to use a note is encrypted with the owner's public key and published in the `NewCommitment` event. This ensures that only the user with the corresponding private key can access it. The public and private keys follow standard RSA conventions. For the address, we currently define it as `hash(private_key)` to quickly validate ownership in circuits, as there is no support for RSA key derivation in Noir. One alternative being explored is using [signatures](https://noir-lang.org/docs/reference/NoirJS/noir_js/functions/ecdsa_secp256k1_verify), though this feature is not yet implemented.

### Relayer

A relayer is a service that can further enhance user privacy. While blockchain calldata does not expose any data about amounts or zk addresses, submitting transactions directly reveals the user's Starknet wallet address, potentially leaving a trace of their participation. To address this, a relayer can submit transactions on behalf of users, effectively obscuring their wallet address and improving privacy.


## How it all works

### Initial Minting Process

Currently, the deployer is responsible for creating the first commitment by specifying the `MERKLE_TREE_INITIAL_ROOT` and emitting the first two notes. This sets the initial supply, and it is then up to the deployer to distribute the tokens. There is no minting process in place at this time.

### Balance discovery

To rediscover a user's commitment, the process works as follows:
1. Fetch all NewCommitment { commitment, enc_output, index } events
2. Fetch all NewNullifier { nullifier_hash } events.
3. Iterate over the commitments:
   - Attempt decryption. If successful, derive the nullifier_hash and check whether it has already been used.
   - If the nullifier_hash hasn't been used, add the commitment to the pool of usable commitments and sum up the value.

### Transfer

On transfer one note is burned and 2 new notes are created, one for the sender change and one for the receiver.

```mermaid
sequenceDiagram
    participant Receiver
    participant Sender
    participant Relayer as Relayer/Sender
    participant Blockchain

    %% receiver shares data with sender
    Receiver->>Sender: address + pub key

    %% rebuild sender balance
    Sender->>+Blockchain: Fetch Commitment events
    Blockchain->>-Sender: Commitments

    %% generate transaction
    Sender->>Sender: Select from my commitments one for transfer
    Sender->>Sender: Generate output commitments (sender, receiver)
    Sender->>Sender: Generate zk proof

    %% submit transaction
    Sender->>+Relayer: transfer(proof, enc_outputs) tx
    Relayer->>+Blockchain: transfer(proof, enc_outputs)
    Blockchain->>Blockchain: emit NewNullifier, NewCommitment x2
    Blockchain->>-Relayer: tx_hash
    Relayer->>-Sender: tx_hash

    %% receiver discovers new balance
    Receiver->>+Blockchain: Fetch Commitment events
    Blockchain->>-Receiver: Commitments
    Receiver->>Receiver: Discover new commitment from transfer
```

Circuit checks
- The input commitment is included in the root and belongs to the sender.
- The nullifierHash is effectively the hash of the nullifier and is attached to the input commitment.
- Ensure no balance is mined or burned and so sum of value of input commitments is equal to sum of output commitments values.
- The output commitments are correct, including the amount and owner of each.
- The new root does not remove any elements from the tree.
- The new root contains both the new commitments.

Some clarifications:
- At the moment we limited input notes to just one, we can easily grow this number by just iterating checks and nullifications.
- Unlike `tornado-core` where the contract maintains and updates the merkle root with all the commitments, in this case we delegate that work to the circuits for cost efficiency and better compatibility of types and hashing functions.

### Application

There're several packages in the overall app and they interact this way:

```mermaid
sequenceDiagram
    participant ui as Ui
    participant api as Api
    participant contracts as Contracts
    participant circuits as DeployedCircuits

    %% load wallet
    ui->>ui: Load or generate user zk wallet

    %% rebuild user balance
    ui->>contracts: Fetch commitments/nullifiers
    contracts->>ui: commitments/nullifiers
    ui->>ui: build user balance and display

    %% build proof 
    ui->>ui: build proof inputs
    ui->>+api: proof inputs
    api->>api: compute proof and build calldata
    api->>-ui: proof calldata

    %% call trasnfer
    ui->>+contracts: transfer(proof, enc_outputs)
    contracts->>+circuits: verify(proof)
    circuits->>-contracts: ok
    contracts->>contracts: update root, emit events, spend note
    contracts->>ui: tx_hash
```

Some clarifications:
- In this context, "circuits" refers to the deployed verifier generated using Garaga.
- The API is ideally not necessary and serves merely as a workaround of current garaga version 0.15.3 not supporting honk vk/proof calldata encoding. This seems to have been introduced in this pr https://github.com/keep-starknet-strange/garaga/pull/288 recently. Not yet published but we can try incorporating it.


## Demo

Current ux goes like this:

User connects argent wallet to pay for transaction gas. A new zk wallet is generated for the user per browser or one is recovered from local storage

![user connects wallet](./assets/demo-1.png)

User can inspect the commitments that form their balance

![commitments before transfer](./assets/demo-2.png)

Sender scans receiver qr code and so automatically filling address and public key

![scan qr code](./assets/demo-3.png)

![filled form](./assets/demo-4.png)

Enter amount and click transfer. Then confirm transaction in wallet. (Example transaction https://sepolia.voyager.online/tx/0x6c6b73fd34c45c05dc9ebdf168c99a0fe1d44fd5e983d7c2bc8187baec87b78?mtm_campaign=argent-redirect&mtm_source=argent&mtm_medium=referral)

![confirm transaction](./assets/demo-5.png)

A little time after receiver has balance available. They can also inspect nullified commitment for sender and new commitment for receiver

![result showcase](./assets/demo-6.png)

# Deployments

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

### transfer

First make sure to update DEPTH accordingly in your circuit. Then generate the cairo contracts with:

```bash
just circuits-generate-verifier transfer

# (cd packages/circuits/transfer && nargo build)
# (cd packages/circuits/transfer && bb write_vk_ultra_keccak_honk -b target/transfer.json -o target/vk.bin)
# Finalized circuit size: 3736
# Log dyadic circuit size: 12
# (cd packages/circuits/transfer && garaga gen --system ultra_keccak_honk --vk target/vk.bin --project-name contracts)
# ⠦ Generating Smart Contract project for ProofSystem.UltraKeccakHonk using vk.bin...
# Done!
# Smart Contract project created:
# /Users/matzapata/git-work/starkware/starkware-private-erc20/packages/circuits/transfer/con
# tracts/
# ├── .tools-versions
# ├── Scarb.lock
# ├── Scarb.toml
# ├── src/
# │   ├── honk_verifier.cairo
# │   ├── honk_verifier_circuits.cairo
# │   ├── honk_verifier_constants.cairo
# │   └── lib.cairo
# └── target/
#     ├── CACHEDIR.TAG
#     └── release/
#         ├── contracts.starknet_artifacts.json
#         ├── contracts_UltraKeccakHonkVerifier.compiled_contract_class.json
#         └── contracts_UltraKeccakHonkVerifier.contract_class.json
# You can now test the main endpoint of the verifier using a proof and `garaga calldata` 
# command.
```

Declare and deploy the contract with 

```bash
just circuits-declare-verifier transfer

# class_hash: 0x056f9a91b0213845099a167ecbe93bfe99ef85f68a6342220727d61dd2edd755
# transaction_hash: 0x0304921ad57cdcee7ab6ccec10fdde3ca99eaef2af3cf034d7f34fa2860ab127

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x056f9a91b0213845099a167ecbe93bfe99ef85f68a6342220727d61dd2edd755
# transaction: https://sepolia.starkscan.co/tx/0x0304921ad57cdcee7ab6ccec10fdde3ca99eaef2af3cf034d7f34fa2860ab127

just circuits-deploy-verifier transfer 0x056f9a91b0213845099a167ecbe93bfe99ef85f68a6342220727d61dd2edd755

# contract_address: 0x002cb91a49726604fb8cd4c2e82b860f845fb622ad63325cbae07b41a713f872
# transaction_hash: 0x03a9dff3f18755c028061910ab600162ef08036edf5a8097987b0a84269b63be

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x002cb91a49726604fb8cd4c2e82b860f845fb622ad63325cbae07b41a713f872
# transaction: https://sepolia.starkscan.co/tx/0x03a9dff3f18755c028061910ab600162ef08036edf5a8097987b0a84269b63be
```


### transfer_from

First make sure to update DEPTH accordingly in your circuit. Then generate the cairo contracts with:

```bash
just circuits-generate-verifier transfer_from

# (cd packages/circuits/transfer_from && nargo build)
# (cd packages/circuits/transfer_from && bb write_vk_ultra_keccak_honk -b target/transfer_from.json -o target/vk.bin)
# Finalized circuit size: 1109
# Log dyadic circuit size: 11
# (cd packages/circuits/transfer_from && garaga gen --system ultra_keccak_honk --vk target/vk.bin --project-name contracts)
# ⠦ Generating Smart Contract project for ProofSystem.UltraKeccakHonk using vk.bin...
# Done!
# Smart Contract project created:
# /Users/matzapata/git-work/starkware/starkware-private-erc20/packages/circuits/transfer_fro
# m/contracts/
# ├── .tools-versions
# ├── Scarb.toml
# └── src/
#     ├── honk_verifier.cairo
#     ├── honk_verifier_circuits.cairo
#     ├── honk_verifier_constants.cairo
#     └── lib.cairo
# You can now test the main endpoint of the verifier using a proof and `garaga calldata` 
# command.
```

Declare and deploy the contract with 

```bash
just circuits-declare-verifier transfer_from

# class_hash: 0x076b2649928b5c1e59c58555ff1d079b096f0813996466b000e286cf49643b80
# transaction_hash: 0x079449212c3a6366346d2a7f0726b9b13ea77ca2c8c5899a8da96da9c120875f

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x076b2649928b5c1e59c58555ff1d079b096f0813996466b000e286cf49643b80
# transaction: https://sepolia.starkscan.co/tx/0x079449212c3a6366346d2a7f0726b9b13ea77ca2c8c5899a8da96da9c120875f

just circuits-deploy-verifier transfer_from 0x076b2649928b5c1e59c58555ff1d079b096f0813996466b000e286cf49643b80

# contract_address: 0x0086fe3a1c7cab01a7551b4ce095fae9bc5a85ccefb34ce90bea444e281c3949
# transaction_hash: 0x00019288b8ef30d5985b189f80f9373bfe5d15777076080eb4e5b8c3cf5664d3

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x0086fe3a1c7cab01a7551b4ce095fae9bc5a85ccefb34ce90bea444e281c3949
# transaction: https://sepolia.starkscan.co/tx/0x00019288b8ef30d5985b189f80f9373bfe5d15777076080eb4e5b8c3cf5664d3
```


### approve

First make sure to update DEPTH accordingly in your circuit. Then generate the cairo contracts with:

```bash
just circuits-generate-verifier approve

# (cd packages/circuits/approve && nargo build)
# (cd packages/circuits/approve && bb write_vk_ultra_keccak_honk -b target/approve.json -o target/vk.bin)
# Finalized circuit size: 251
# Log dyadic circuit size: 8
# (cd packages/circuits/approve && garaga gen --system ultra_keccak_honk --vk target/vk.bin --project-name contracts)
# ⠦ Generating Smart Contract project for ProofSystem.UltraKeccakHonk using vk.bin...
# Done!
# Smart Contract project created:
# /Users/matzapata/git-work/starkware/starkware-private-erc20/packages/circuits/approve/cont
# racts/
# ├── .tools-versions
# ├── Scarb.toml
# └── src/
#     ├── honk_verifier.cairo
#     ├── honk_verifier_circuits.cairo
#     ├── honk_verifier_constants.cairo
#     └── lib.cairo
# You can now test the main endpoint of the verifier using a proof and `garaga calldata` 
# command.
```

Declare and deploy the contract with 

```bash
just circuits-declare-verifier approve

# class_hash: 0x0005ab98bd08bbfc4fac40994f37bab41528ea8ee4eefbbcc9cf7244bf7782d2
# transaction_hash: 0x01cd9e75a8504091b0438cb6dfc9bb9d4c7ca597927aefb764ba0980272c1907

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x0005ab98bd08bbfc4fac40994f37bab41528ea8ee4eefbbcc9cf7244bf7782d2
# transaction: https://sepolia.starkscan.co/tx/0x01cd9e75a8504091b0438cb6dfc9bb9d4c7ca597927aefb764ba0980272c1907

just circuits-deploy-verifier approve 0x0005ab98bd08bbfc4fac40994f37bab41528ea8ee4eefbbcc9cf7244bf7782d2

# contract_address: 0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371
# transaction_hash: 0x075498d0bfa5c3be4afe4181c4d8c96c5c9fa69cbbe50a3ed8d8e294dfcc1d35

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x028236f4aad88c151a9776c3b23427c96e841e8d1f3885f94d5fd8d8039f7371
# transaction: https://sepolia.starkscan.co/tx/0x075498d0bfa5c3be4afe4181c4d8c96c5c9fa69cbbe50a3ed8d8e294dfcc1d35
```

## Contracts deployment

Deployment with just command (Same for verifier if needed). First go to `src/privado/constants` and update properly.

```bash
just contracts-declare

# class_hash: 0x0248dda69d0d5059e128807f28a6e0815083d87bd02e3b0a787f0aa330fccee3
# transaction_hash: 0x045f36464efada127f3d09b71e3752287f7f22db4aee1897fc926bc548b8f15a

# To see declaration details, visit:
# class: https://sepolia.starkscan.co/class/0x0248dda69d0d5059e128807f28a6e0815083d87bd02e3b0a787f0aa330fccee3
# transaction: https://sepolia.starkscan.co/tx/0x045f36464efada127f3d09b71e3752287f7f22db4aee1897fc926bc548b8f15a

just contracts-deploy 0x0248dda69d0d5059e128807f28a6e0815083d87bd02e3b0a787f0aa330fccee3

# contract_address: 0x06caa2aedd6e03a48c74bf44f8a37b325db057b45a4ef6d626048d33c5605b00
# transaction_hash: 0x06f23c3f39df68ddae8ef80a7d756ab15e814942f330dd79ec8a410ba0de163d

# To see deployment details, visit:
# contract: https://sepolia.starkscan.co/contract/0x06caa2aedd6e03a48c74bf44f8a37b325db057b45a4ef6d626048d33c5605b00
# transaction: https://sepolia.starkscan.co/tx/0x06f23c3f39df68ddae8ef80a7d756ab15e814942f330dd79ec8a410ba0de163d
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
