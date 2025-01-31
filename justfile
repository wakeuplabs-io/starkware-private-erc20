
RPC_URL := "https://starknet-sepolia.infura.io/v3/79b316faeb34447d8b9dfe185a2a67bc"

VERIFIER_ADDRESS := "0x0537951480e082dfa91db5777d0d8509335dd2881e9d7135805a2efbdc42b88d"
NAME := "0x4E616D65"
SYMBOL := "0x53494D"
DECIMALS := "0x6"
LEVELS := "0xC"
MINT_COMMITMENT := "0x0"
MINT_AMOUNT_ENC := "0x0"

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
    (cd packages/contracts && sncast --account deployer deploy --url {{RPC_URL}} --class-hash {{class_hash}} --fee-token ETH --constructor-calldata {{NAME}} {{SYMBOL}} {{DECIMALS}} {{LEVELS}} {{MINT_COMMITMENT}} {{MINT_AMOUNT_ENC}} {{VERIFIER_ADDRESS}})

contracts-declare-verifier:
   (cd packages/contracts && sncast --account deployer declare --url {{RPC_URL}} --contract-name TransferVerifierMock --fee-token ETH)

contracts-deploy-verifier class_hash:
   (cd packages/contracts && sncast --account deployer deploy --url {{RPC_URL}} --class-hash {{class_hash}} --fee-token ETH)

contracts-deployer-account-create:
    (cd packages/contracts && sncast account create -n deployer --url {{RPC_URL}})

contracts-deployer-account-deploy:
    (cd packages/contracts && sncast account deploy --name deployer --url {{RPC_URL}} --fee-token ETH)

