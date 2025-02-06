import "./home.css";
import { createFileRoute } from "@tanstack/react-router";
import AccountManager from "@/components/account-manager";
import Balance from "@/components/balance";
import Transfer from "@/components/transfer";
import ConnectButton from "@/components/connect-button";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  return (
    <div className="home-container">
      <h1 className="text-xl font-bold mb-4">Starkware-Private-ERC20</h1>

      <div className="space-y-4">
        <div className="text-center">
          <ConnectButton />
        </div>

        <AccountManager />
        
        <Balance />
        
        <Transfer />
      </div>
    </div>
  );
}

export default Index;
