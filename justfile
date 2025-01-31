
RPC_URL := "https://starknet-sepolia.public.blastapi.io/rpc/v0_7"

# contracts

contracts-test:
    (cd packages/contracts && snforge test)

contracts-fmt:
    (cd packages/contracts && scarb fmt)

contracts-deploy:
    (cd packages/contracts && sncast --account deployer script run deploy --url {{RPC_URL}} --package deploy)

contracts-declare-privado:
    (cd packages/contracts && sncast --account deployer declare --url {{RPC_URL}} --contract-name Privado --fee-token ETH)

contracts-deploy-privado class_hash:
    (cd packages/contracts && sncast --account deployer deploy --url {{RPC_URL}} --class-hash {{class_hash}} --fee-token ETH)

contracts-declare-verifier:
   (cd packages/contracts && sncast --account deployer declare --url {{RPC_URL}} --contract-name TransferVerifierMock --fee-token ETH)

contracts-deploy-verifier class_hash:
   (cd packages/contracts && sncast --account deployer deploy --url {{RPC_URL}} --class-hash {{class_hash}} --fee-token ETH)

contracts-deployer-account-create:
    (cd packages/contracts && sncast account create -n deployer --url {{RPC_URL}})

contracts-deployer-account-deploy:
    (cd packages/contracts && sncast account deploy --name deployer --url {{RPC_URL}} --fee-token ETH)

