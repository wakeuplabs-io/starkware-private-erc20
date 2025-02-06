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
    <div className="h-screen w-screen">
      <ConnectButton className="absolute top-4 right-4" />

      <div className="flex justify-center items-center flex-col h-screen">
        <h1 className="text-2xl font-bold mb-4">Starkware-Private-ERC20</h1>

        <div className="space-y-4">
          <AccountManager />
          <Balance />
          <Transfer />
        </div>
      </div>
    </div>
  );
}

export default Index;
