# Private ERC20

## Overview

Design is inspired in privacy pools like [tornado core](https://github.com/tornadocash/tornado-core/tree/master) and [zcash](https://github.com/zcash/orchard)

## Methods

### transfer

- Receiver generates a one time `address H(nullifier + secret)`. It also generates a Rsa keypair and sends both the one time address and the public key of the Rsa keypair.
- Sender creates commitment with H(receiver_one_time_address, amount) === H(H(nullifier + secret), amount)
- Sender encrypts amount with Receiver public key such that only him with his private key can decrypt.
- Sender takes calls contract with `notes` we will use to make the payment. And proof that these notes:
   - Hold enough balance  pay
   - New notes are valid
   - Used notes belong to the tree and match the entered nullifier_hash
- At this point nor commitment used by sender to pay or amount of it, nor the receiver has revealed any of his identity, and the funds are ready to be used by the receiver.


```
function transfer(
   proof, // notes have enough balance, belong to tree and new notes are correct
   root, // to proof notes belong to merkle tree
   nullifier_hash, // notes used by sender that will be nullified
   new_notes{ enc_amount, commitment }[2], // [sender, receiver]
) external nonReentrant {
   assert(is_known(_root) == true, "Cannot find your merkle root");
   assert(nullified_notes[nullifier_hash] == false, "Note was already spent");
   assert(
      verifier.verifyTx(
         _proof,
         [...]
      ),
      "Invalid transfer proof"
   );

   // spend the notes
   nullified_notes[nullifier_hash] = true;

   // create new notes for receiver and sender
   let index_sender = merkle_tree.insert(new_notes[0]);
   let index_receiver = merkle_tree.insert(new_notes[1]);
   
   //  emit events for each note created
   emit NewNote(new_notes[0].commitment, new_notes[0].enc_amount, index_sender, timestamp);
   emit NewNote(new_notes[1].commitment, new_notes[1].enc_amount, index_receiver, timestamp);
}
```


bb write_vk_ultra_keccak_honk -b ./packages/circuit/target/transfer.json -o ./packages/circuit/target/transfer-vk.bin

garaga gen --system ultra_keccak_honk --vk ./packages/circuit/target/transfer-vk.bin

```
function transfer(
   proof, // notes have enough balance, belong to tree and new notes are correct
   root, // to proof notes belong to merkle tree
   nullifier_hash, // notes used by sender that will be nullified
   new_notes{ enc_amount, commitment }[2], // [sender, receiver]
) external nonReentrant {
   assert(is_known(_root) == true, "Cannot find your merkle root");
   assert(nullified_notes[nullifier_hash] == false, "Note was already spent");
   assert(
      verifier.verifyTx(
         _proof,
         [...]
      ),
      "Invalid transfer proof"
   );

   // spend the notes
   nullified_notes[nullifier_hash] = true;

   // create new notes for receiver and sender
   let index_sender = merkle_tree.insert(new_notes[0]);
   let index_receiver = merkle_tree.insert(new_notes[1]);
   
   //  emit events for each note created
   emit NewNote(new_notes[0].commitment, new_notes[0].enc_amount, index_sender, timestamp); 
   emit NewNote(new_notes[1].commitment, new_notes[1].enc_amount, index_receiver, timestamp);
}
```

