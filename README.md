# Private ERC20

## Overview

Design is inspired in [tornado core](https://github.com/tornadocash/tornado-core/tree/master) with some differences to fit the requirements:
- Partial spending of notes
- Built as a token itself with transfers instead of deposits and withdrawals

## Methods

### transfer

- Receiver generates commitment and send to sender
- Sender generates proof of balances for transfer and calls the transfer function. Balance for nullifierHash or commitment will be reduced and incremented in receiver commitment.
- At this point nor commitment used by sender to pay or amount of it, nor the receiver has revealed any of his identity, and the funds are ready to be used by the receiver.

Some notes:
- Commitments can be partially nullified.
- Circuits proof the inclusion of the commitment in the merkle tree, knowledge over the nullifier and therefore ownership over this commitment and that the balance is enough to make the payment.

```
function transfer(
   Proof memory _proof,
   bytes32 _root,
   bytes32 _nullifierHash, // ideally an array to use multiple in a same payment
   address _receiver_commitment,
   uint256 amount,
) external nonReentrant {
   require(isKnownRoot(_root) == true, "Cannot find your merkle root");

   uint256 nullified = nullifierBalances[_nullifierHash]
   require(
      verifier.verifyTx(
         _proof,
         [uint256(_root), uint256(_nullifierHash), nullified, amount]
      ),
      "Invalid transfer proof"
   );

   nullifierBalances[_nullifierHash] = nullified - amount;

   // create new commitment for receiver 
   uint256 insertedIndex = _insert(_commitment);
   commitments[_commitment] = true;

   //  emit events
}
```

### approve

Proof I own commitments, if positive update allowances mapping

```
allowances:
 [_nullifierHash]: spender, amount

function approve(
   Proof memory _proof,
   bytes32 _root,
   bytes32 _nullifierHash, // ideally array
   uint256 amount,
   address spender
)
```

### transferFrom

```
function transferFrom(
   bytes32 _nullifierHash, // ideally array
   address to,
)
```

### balance

Client side check all commitments I own and subtract partial spending from them.
