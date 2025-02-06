import { useTransfer } from "@/hooks/useTransfer";
import "./transfer.css";
import { useCallback, useState } from "react";
import { MerkleTree } from "@/utils/merkle-tree";
import { BarretenbergService } from "@/services/bb.service";
import { Fr } from "@aztec/bb.js";

const Transfer = () => {
  const { sendTransfer, loading } = useTransfer();
  const [recipientAddress, setRecipientAddress] = useState("");
  const [recipientPublicKey, setRecipientPublicKey] = useState("");
  const [amount, setAmount] = useState(0);

  const onTransfer = useCallback(async () => {
    // const tree = new MerkleTree()
    // await tree.addCommitment(1n)
    // await tree.addCommitment(2n)
    // await tree.addCommitment(4n)
    // await tree.addCommitment(5n)
    // await tree.addCommitment(6n)
    // await tree.addCommitment(7n)

    // console.log("tree", tree.getProof(6n))
    // console.log("tree", tree.getProof(7n))


    sendTransfer({
      to: {
        address: BigInt(recipientAddress),
        publicKey: BigInt(recipientPublicKey),
      },
      amount: BigInt(amount),
    })
      .then(() => {
        window.alert("Transfer successful");
      })
      .catch((error) => {
        console.log(error);
        window.alert("Transfer failed");
      });

    // const privateKey = BigInt("0x2efe4d50e62d08f1335a7d8b6e8cb0a1b92d68e9bc34fcab1f547b2588d36ff1")
    // const publicKey = BigInt("0x9fe40de6a38adf7cb7ed7afbd20a65d068682ab1090fd6274a44b10be0cfad10");
    // const address = BigInt("0xf4280fa36dd274233822111013be2d770e02332ac2766ae093aa25ee33a2d31")

    // const note = await BarretenbergService.generateNote(
    //   address,
    //   publicKey,
    //   BigInt(100000000000)
    // );
    

    // const tree = new MerkleTree();

    // // root 0x2f3263cd8488a893cc8d2b48d874723b599027e91fa355ed050bf23d49020310
    // // enc Bp_RXfUSztR04BFmuvvZGUKZyiKPRoAmNWbMJnWlQWeCBBHYaN89O7foXaG4rxGR6maX6PLsNEjYgqf-0liDl6FRlx_DkAbX-lsvBBE1k1p3RVhVBrRRnZ4lrel65LZJL_POTwqs38iZnaxzRS-Z_9RPlQ
    // // commitment 0x1c19b4e2cde7662f125ca488852bf75cd26049bb4027c19847f04b8d9abe747b

    // await tree.addCommitment(note.commitment);
    // await tree.addCommitment(BigInt(0));

    // console.log("0x" + tree.getRoot().toString(16));
    // console.log(note.encOutput);
    // console.log("0x" + note.commitment.toString(16));

  }, [amount, recipientAddress, recipientPublicKey, sendTransfer]);

  return (
    <div className="transfer-container">
      <h2 className="transfer-title">Transfer</h2>

      <input
        className="transfer-input"
        type="text"
        placeholder="Recipient Address"
        value={recipientAddress}
        onChange={(e) => setRecipientAddress(e.target.value)}
      />

      <input
        className="transfer-input"
        type="text"
        placeholder="Recipient Public Key"
        value={recipientPublicKey}
        onChange={(e) => setRecipientPublicKey(e.target.value)}
      />

      <input
        className="transfer-input"
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={(e) => setAmount(parseInt(e.target.value))}
      />

      <button
        onClick={onTransfer}
        className="transfer-button"
        disabled={loading}
      >
        {loading ? "Transferring..." : "Transfer "}
      </button>
    </div>
  );
};

export default Transfer;
