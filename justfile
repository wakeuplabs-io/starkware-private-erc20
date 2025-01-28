
# contracts

contracts-tests:
    (cd packages/contracts && snforge test)

contracts-fmt:
    (cd packages/contracts && scarb fmt)