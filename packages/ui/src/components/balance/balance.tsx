import { useTokenData } from "@/hooks/useTokenData";
import "./balance.css";

const Balance = () => {
  const { balance, tokenAddress, balanceError } = useTokenData();

  if (balanceError) {
    return <div className="balance-error">Failed to load balance: {balanceError.message}</div>;
  }

  if (!balance) {
    return <div className="balance-loading">Loading balance...</div>;
  }

  return (
    <div className="balance-container">
      <p className="balance-token">Token Address: {tokenAddress}</p>
      <h2 className="balance-title">Your Balance</h2>
      <p className="balance-amount">{balance.toString()} Tokens</p>
    </div>
  );
};

export default Balance;
