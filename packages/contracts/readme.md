
# Deployment

Create the deployer account

```bash
just contracts-deployer-account-create

address: 0x0528604705c912b3a6debc3bb63370659b884fb370191c9c48ccb59a9b9f3e24
max_fee: 117743078418
message: Account successfully created. Prefund generated address with at least <max_fee> STRK tokens or an equivalent amount of ETH tokens. It is good to send more in the case of higher demand.
```

Prefund generated address with at least <max_fee> STRK tokens or an equivalent amount of ETH tokens and then run

```bash
just contracts-deployer-account-deploy
```
