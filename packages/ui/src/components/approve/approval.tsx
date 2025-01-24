import { useState } from "react";
import "./approval.css";

const Approval = ({
  onSetAllowance,
  maxBalance,
}: {
  onSetAllowance: (spender: string, amount: number) => void;
  maxBalance: number;
}) => {
  const [spender, setSpender] = useState("");
  const [amount, setAmount] = useState(0);

  const handleAllowance = () => {
    if (amount > 0 && amount <= maxBalance) {
      onSetAllowance(spender, amount);
    } else {
      alert("Invalid amount");
    }
  };

  return (
    <div className="approval-container">
      <h2 className="approval-title">Set Allowance</h2>
      <input
        className="approval-input"
        type="text"
        placeholder="Spender Address"
        value={spender}
        onChange={(e) => setSpender(e.target.value)}
      />
      <input
        className="approval-input"
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={(e) => setAmount(Number(e.target.value))}
        max={maxBalance}
      />
      <button className="approval-button" onClick={handleAllowance}>
        Set Allowance
      </button>
    </div>
  );
};

export default Approval;
