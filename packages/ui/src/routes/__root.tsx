import { useCallback } from "react";
import { Button } from "@/components/ui/button";
import { WakeUpLogo } from "@/components/wakeup-logo";
import { useAccount, useConnect, useDisconnect } from "@starknet-react/core";
import { createRootRoute, Outlet } from "@tanstack/react-router";
import { StarknetkitConnector, useStarknetkitConnectModal } from "starknetkit";

export const Route = createRootRoute({
  component: () => (
    <div className="w-screen h-screen flex flex-col">
      <RootLayout />
    </div>
  ),
});

function RootLayout() {
  const { address } = useAccount();
  const { disconnect } = useDisconnect();
  const { connect, connectors } = useConnect();
  const { starknetkitConnectModal } = useStarknetkitConnectModal({
    connectors: connectors as StarknetkitConnector[],
  });

  const onConnectWallet = useCallback(async () => {
    const { connector } = await starknetkitConnectModal();
    if (!connector) {
      return;
    }
    connect({ connector });
  }, []);

  if (address) {
    return (
      <div className="min-h-screen flex flex-col">
        <header className=" shadow-md">
          <div className="flex items-center justify-between px-4 py-8 md:px-0 max-w-3xl mx-auto w-full">
            <WakeUpLogo className="h-[36px] hidden md:block" />
            <img src="/starknet-logo.png" alt="" className="h-[28px]" />
            <Button
              onClick={() => disconnect()}
              className="h-[30px] rounded-full text-xs font-medium"
            >
              Disconnect
            </Button>
          </div>
        </header>

        <main className="px-4 md:px-8 flex flex-col justify-between items-center bg-muted flex-1 pb-12">
          <div className="max-w-3xl mx-auto w-full pt-8">
            <Outlet />
          </div>

          <WakeUpLogo className="h-[42px] w-[120px] md:hidden mt-10" />
        </main>
      </div>
    );
  }

  return (
    <div className="h-screen w-screen px-6 md:px-24 pt-16 md:p-0 relative md:flex md:justify-center md:items-center">
      <div className="mx-auto max-w-5xl w-full">
        <div className="rounded-3xl border border-[#35269A] p-8 md:p-24 pt-12 bg-gradient-to-t from-[#DCE9FF] to-[#F0DBF9] max-w-5xl w-full">
          <img
            src="/starknet-logo.png"
            alt=""
            className="mb-16 max-w-[300px] w-full"
          />

          <div className="mb-24 text-xl text-muted-foreground max-w-lg">
            <span className="font-semibold">Welcome!</span> Send and receive
            funds privately, with no intermediaries. Connect your wallet to get
            started.
          </div>

          <div className="flex justify-between items-end">
            <Button
              onClick={onConnectWallet}
              className="w-full h-[90px] md:max-w-80 rounded-lg text-lg"
            >
              Connect Wallet
            </Button>

            <WakeUpLogo className="hidden md:block h-16" />
          </div>
        </div>

        <div className="text-justify mt-4 text-sm text-muted-foreground">
          Disclaimer: This is a project for demo purposes, developed within the
          framework of NoirCon 1 at ETH Denver. At this stage, it is in PoC
          format and does not include all compliance, security, and edge case
          checks required. It will require many additional QA rounds, extra
          development & design iterations for it to be mainnet-ready.
        </div>
      </div>

      <div className="md:hidden flex justify-center py-10">
        <WakeUpLogo className="h-10" />
      </div>
    </div>
  );
}
