import ConnectButton from "@/components/connect-button";
import { createFileRoute } from "@tanstack/react-router";
import "./home.css";
import { useAccount } from "@starknet-react/core";
import Dashboard from "./dashboard";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  const { status } = useAccount();
  return (
    <div className="home-container">
      <h1 className="home-title">Private-ERC20</h1>
      <div className="home-button">
        <ConnectButton />
      </div>
      {status === "connected" && (
        <Dashboard />
      )}
    </div>
  );
}

export default Index;
