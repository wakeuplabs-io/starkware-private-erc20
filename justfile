
RPC_URL := "https://starknet-sepolia.public.blastapi.io/rpc/v0_7"
CIRCUIT_ROOT := "packages/circuits"
CONTRACTS_ROOT := "packages/contracts"
UI_ROOT := "packages/ui"
API_ROOT := "packages/api"

# ui

ui-run:
    (cd {{UI_ROOT}} && npm run dev)

# api

api-run:
    (cd {{API_ROOT}} && docker-compose up)

# circuits transfer

circuits-test circuit:
    (cd {{CIRCUIT_ROOT}}/{{circuit}} && nargo test --show-output)

circuits-check circuit:
    (cd {{CIRCUIT_ROOT}}/{{circuit}} && nargo check)

circuits-build circuit:
    (cd {{CIRCUIT_ROOT}}/{{circuit}} && nargo build)

circuits-fmt circuit:
    (cd {{CIRCUIT_ROOT}}/{{circuit}} && nargo fmt)

circuits-proof circuit:
    (cd {{CIRCUIT_ROOT}}/{{circuit}} && nargo execute witness && bb prove_ultra_keccak_honk -b target/{{circuit}}.json -w target/witness.gz -o target/proof.bin && garaga calldata --system ultra_keccak_honk --vk target/vk.bin --proof target/proof.bin --format array > calldata.txt)

circuits-generate-verifier circuit: 
    (cd {{CIRCUIT_ROOT}}/{{circuit}} && nargo build)
    (cd {{CIRCUIT_ROOT}}/{{circuit}} && bb write_vk_ultra_keccak_honk -b target/{{circuit}}.json -o target/vk.bin)
    (cd {{CIRCUIT_ROOT}}/{{circuit}} && garaga gen --system ultra_keccak_honk --vk target/vk.bin --project-name contracts)

circuits-declare-verifier circuit:
    (cd {{CIRCUIT_ROOT}}/{{circuit}}/contracts && sncast --account deployer declare --url {{RPC_URL}} --contract-name UltraKeccakHonkVerifier --fee-token ETH)

circuits-deploy-verifier circuit class_hash:
    (cd {{CIRCUIT_ROOT}}/{{circuit}}/contracts && sncast --account deployer deploy --url {{RPC_URL}} --class-hash {{class_hash}} --fee-token ETH)


# contracts

contracts-test:
    (cd {{CONTRACTS_ROOT}} && snforge test)

contracts-fmt:
    (cd {{CONTRACTS_ROOT}} && scarb fmt)

contracts-declare:
    (cd {{CONTRACTS_ROOT}} && sncast --account deployer declare --url {{RPC_URL}} --contract-name Privado --fee-token ETH)

contracts-deploy class_hash:
    (cd {{CONTRACTS_ROOT}} && sncast --account deployer deploy --url {{RPC_URL}} --class-hash {{class_hash}} --fee-token ETH)

contracts-deployer-account-create:
    (cd {{CONTRACTS_ROOT}} && sncast account create -n deployer --url {{RPC_URL}})

contracts-deployer-account-deploy:
    (cd {{CONTRACTS_ROOT}} && sncast account deploy --name deployer --url {{RPC_URL}} --fee-token ETH)

