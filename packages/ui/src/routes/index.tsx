import Transfer from "@/components/transfer";
import { Button, buttonVariants } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { createFileRoute } from "@tanstack/react-router";
import { ArrowDown, ArrowUpRight, List } from "lucide-react";
import { useState } from "react";

export const Route = createFileRoute("/")({
  component: Index,
});

enum Tab {
  Notes = "notes",
  Send = "send",
  Receive = "receive",
}

function Index() {
  const [tab, setTab] = useState<Tab>(Tab.Notes);

  return (
    <div className="w-full">
      <div className="w-full space-y-8 lg:space-y-4 mb-12">
        <div className="flex justify-between w-full">
          <h1 className="text-2xl lg:text-4xl font-bold">Privado</h1>
          <div className="relative">
            <div className="text-3xl lg:text-4xl font-bold">1217.12</div>
            <div className="absolute bottom-0 translate-y-full right-0 text-sm lg:text-base">
              My balance
            </div>
          </div>
        </div>

        <div className="gap-2 grid grid-cols-3 max-w-sm">
          <button
            onClick={() => setTab(Tab.Notes)}
            className={cn(
              "h-9 px-3 border border-input hover:bg-accent bg-transparent rounded-lg border-primary flex items-center gap-1",
              {
                "bg-gradient-to-r from-[#9A5583] via-[#35269A] to-[#181972] text-white border-none":
                  tab === Tab.Notes,
              }
            )}
          >
            <List className="h-4" /> Notes
          </button>
          <button
            onClick={() => setTab(Tab.Send)}
            className={cn(
              "h-9 px-3 border border-input hover:bg-accent bg-transparent rounded-lg border-primary flex items-center gap-1",
              {
                "bg-gradient-to-r from-[#9A5583] via-[#35269A] to-[#181972] text-white border-none":
                  tab === Tab.Send,
              }
            )}
          >
            <ArrowUpRight className="h-4" /> Send
          </button>
          <button
            onClick={() => setTab(Tab.Receive)}
            className={cn(
              "h-9 px-3 border border-input hover:bg-accent bg-transparent rounded-lg border-primary flex items-center gap-1",
              {
                "bg-gradient-to-r from-[#9A5583] via-[#35269A] to-[#181972] text-white border-none":
                  tab === Tab.Receive,
              }
            )}
          >
            <ArrowDown className="h-4" /> Receive
          </button>
        </div>
      </div>

      <Transfer />
      {/* notes */}
      {/* send */}
      {/* transfer */}
    </div>
  );
}

export default Index;
