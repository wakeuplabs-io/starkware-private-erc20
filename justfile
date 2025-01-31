
RPC_URL := "https://starknet-sepolia.infura.io/v3/79b316faeb34447d8b9dfe185a2a67bc"

# contracts

contracts-test:
    (cd packages/contracts && snforge test)

contracts-fmt:
    (cd packages/contracts && scarb fmt)

contracts-deploy:
    (cd packages/contracts && sncast --account deployer script run deploy --url {{RPC_URL}} --package deploy)

contracts-deployer-account-create:
    (cd packages/contracts && sncast account create -n deployer --url {{RPC_URL}})

contracts-deployer-account-deploy:
    (cd packages/contracts && sncast account deploy --name deployer --url {{RPC_URL}} --fee-token ETH)

