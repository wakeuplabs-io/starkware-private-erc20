import { useApprove } from "@/hooks/useApprove";
import { useCallback, useState } from "react";
import { Button } from "../ui/button";
import "./approve.css";

const Approve = () => {
  const { sendApprove, loading } = useApprove();
  const [spenderAddress, setSpenderAddress] = useState("");
  const [amount, setAmount] = useState(0);

  const onApprove = useCallback(async () => {
    sendApprove({
      spender: BigInt(spenderAddress),
      amount: BigInt(amount),
    })
      .then(() => {
        window.alert("Approval successful");
      })
      .catch((error: unknown) => {
        console.error(error);
        window.alert("Approval failed");
      });
  }, [amount, spenderAddress, sendApprove]);

  return (
    <div className="approve-container">
      <h2 className="text-lg text-center">Approve</h2>

      <input
        className="approve-input"
        type="text"
        placeholder="Spender Address"
        value={spenderAddress}
        onChange={(e) => setSpenderAddress(e.target.value)}
      />

      <input
        className="approve-input"
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={(e) => setAmount(parseInt(e.target.value))}
      />

      <Button className="w-full mt-2" onClick={onApprove} disabled={loading}>
        {loading ? "Approving..." : "Approve"}
      </Button>
    </div>
  );
};

export default Approve;
