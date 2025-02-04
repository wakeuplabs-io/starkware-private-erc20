
RPC_URL := "https://starknet-sepolia.public.blastapi.io/rpc/v0_7"
TRANSFER_CIRCUIT_ROOT := "packages/circuits/transfer"
CONTRACTS_ROOT := "packages/contracts"

# circuits

circuits-test:
    (cd {{TRANSFER_CIRCUIT_ROOT}} && nargo test --show-output)

circuits-check:
    (cd {{TRANSFER_CIRCUIT_ROOT}} && nargo check)

circuits-build:
    (cd {{TRANSFER_CIRCUIT_ROOT}} && nargo build)

circuits-proof:
    (cd {{TRANSFER_CIRCUIT_ROOT}} && nargo execute witness && bb prove_ultra_keccak_honk -b target/transfer.json -w target/witness.gz -o target/proof.bin && garaga calldata --system ultra_keccak_honk --vk target/vk.bin --proof target/proof.bin --format array > calldata.txt)

circuits-generate-verifier: circuits-build
    (cd {{TRANSFER_CIRCUIT_ROOT}} && bb write_vk_ultra_keccak_honk -b target/transfer.json -o target/vk.bin)
    (cd {{TRANSFER_CIRCUIT_ROOT}} && garaga gen --system ultra_keccak_honk --vk target/vk.bin --project-name contracts)

circuits-declare-verifier:
    (cd {{TRANSFER_CIRCUIT_ROOT}}/contracts && sncast --account deployer declare --url {{RPC_URL}} --contract-name UltraKeccakHonkVerifier --fee-token ETH)

circuits-deploy-verifier class_hash:
    (cd {{TRANSFER_CIRCUIT_ROOT}}/contracts && sncast --account deployer deploy --url {{RPC_URL}} --class-hash {{class_hash}} --fee-token ETH)

# contracts

contracts-test:
    (cd {{CONTRACTS_ROOT}} && snforge test)

contracts-fmt:
    (cd {{CONTRACTS_ROOT}} && scarb fmt)

contracts-deploy:
    (cd {{CONTRACTS_ROOT}} && sncast --account deployer script run deploy --url {{RPC_URL}} --package deploy)

contracts-declare-privado:
    (cd {{CONTRACTS_ROOT}} && sncast --account deployer declare --url {{RPC_URL}} --contract-name Privado --fee-token ETH)

contracts-deploy-privado class_hash:
    (cd {{CONTRACTS_ROOT}} && sncast --account deployer deploy --url {{RPC_URL}} --class-hash {{class_hash}} --fee-token ETH)

contracts-declare-verifier:
   (cd {{CONTRACTS_ROOT}} && sncast --account deployer declare --url {{RPC_URL}} --contract-name TransferVerifierMock --fee-token ETH)

contracts-deploy-verifier class_hash:
   (cd {{CONTRACTS_ROOT}} && sncast --account deployer deploy --url {{RPC_URL}} --class-hash {{class_hash}} --fee-token ETH)

contracts-deployer-account-create:
    (cd {{CONTRACTS_ROOT}} && sncast account create -n deployer --url {{RPC_URL}})

contracts-deployer-account-deploy:
    (cd {{CONTRACTS_ROOT}} && sncast account deploy --name deployer --url {{RPC_URL}} --fee-token ETH)

