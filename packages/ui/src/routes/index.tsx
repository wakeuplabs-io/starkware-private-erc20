import ConnectButton from "@/components/connect-button";
import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  return (
    <div>
      <h1>Welcome to Starkpayment</h1>
      <ConnectButton />
    </div>
  );
};
