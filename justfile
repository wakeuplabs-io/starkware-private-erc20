
RPC_URL := "https://starknet-sepolia.public.blastapi.io/rpc/v0_7"

# contracts

contracts-test:
    (cd packages/contracts && snforge test)

contracts-fmt:
    (cd packages/contracts && scarb fmt)

contracts-deploy:
    (cd packages/contracts && sncast script run deploy --url {{RPC_URL}} --package deploy)