import { Header } from "@/components/header";
import { Button } from "@/components/ui/button";
import { useAccount, useConnect } from "@starknet-react/core";
import { createFileRoute } from "@tanstack/react-router";
import { useCallback } from "react";
import { StarknetkitConnector, useStarknetkitConnectModal } from "starknetkit";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  return <div>Home</div>
}

export default Index;
