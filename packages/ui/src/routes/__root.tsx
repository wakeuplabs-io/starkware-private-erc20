import { Button } from "@/components/ui/button";
import { useAccount, useConnect } from "@starknet-react/core";
import { createRootRoute, Outlet } from "@tanstack/react-router";
import React, { useCallback } from "react";
import { StarknetkitConnector, useStarknetkitConnectModal } from "starknetkit";

const TanStackRouterDevtools =
  import.meta.env.NODE_ENV === "production"
    ? () => null // Render nothing in production
    : React.lazy(() =>
        import("@tanstack/router-devtools").then((res) => ({
          default: res.TanStackRouterDevtools,
        }))
      );

export const Route = createRootRoute({
  component: () => (
    <div className="w-screen h-screen flex flex-col">
      <RootLayout />
      <TanStackRouterDevtools />
    </div>
  ),
});

function RootLayout() {
  const { connect, connectors } = useConnect();
  const { address } = useAccount();
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
          <div className="flex items-center justify-between p-8 lg:px-0 max-w-xl mx-auto w-full">
            <img
              src="/wakeup-powered.png"
              alt=""
              className="h-[36px] hidden lg:block"
            />
            <img src="/starknet-logo.png" alt="" className="h-[28px]" />
            <Button className="h-[30px] rounded-full text-xs font-medium">
              Disconnect
            </Button>
          </div>
        </header>

        <main className="px-8 flex flex-col justify-between items-center bg-muted flex-1 pb-12">
          <div className="max-w-xl mx-auto w-full pt-8">
            <Outlet />
          </div>

          <img
            src="/wakeup-powered.png"
            alt=""
            className="h-[42px] w-[120px] lg:hidden"
          />
        </main>
      </div>
    );
  }

  return (
    <div className="h-screen w-screen px-6 lg:px-24 pt-16 lg:p-0 relative lg:flex lg:justify-center lg:items-center">
      <div className="rounded-3xl border border-[#35269A] p-8 lg:p-24 pt-12 bg-gradient-to-t from-[#DCE9FF] to-[#F0DBF9] max-w-5xl w-full">
        <img
          src="/starknet-logo.png"
          alt=""
          className="mb-16 h-[70px] max-w-[300px]"
        />

        <div className="mb-24 text-xl text-muted-foreground max-w-lg">
          <span className="font-semibold">Welcome!</span> Send and receive funds
          privately, with no intermediaries. Connect your wallet to get started.
        </div>

        <div className="flex justify-between items-end">
          <Button
            onClick={onConnectWallet}
            className="w-full h-[90px] max-w-80 rounded-lg text-lg"
          >
            Connect Wallet
          </Button>

          <img
            src="/wakeup-powered.png"
            alt=""
            className="hidden lg:block h-16"
          />
        </div>
      </div>

      <div className="lg:hidden absolute left-0 right-0 bottom-12  flex justify-center">
        <img src="/wakeup-powered.png" alt="" className="h-10" />
      </div>
    </div>
  );
}
