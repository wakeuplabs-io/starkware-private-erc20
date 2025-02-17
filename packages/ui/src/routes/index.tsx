import { Approve } from "@/components/approve";
import { Notes } from "@/components/notes";
import { Receive } from "@/components/receive";
import { Transfer } from "@/components/transfer";
import { useBalance } from "@/hooks/use-balance";
import { cn, formatTokenAmount } from "@/lib/utils";
import { createFileRoute } from "@tanstack/react-router";
import { ArrowDown, ArrowUpRight, List, Check, Eye, EyeOff } from "lucide-react";
import { useState } from "react";

export const Route = createFileRoute("/")({
  component: Index,
});

enum Tab {
  Notes = "notes",
  Send = "send",
  Receive = "receive",
  Approve = "approve",
}

function Index() {
  const { balance } = useBalance();
  const [tab, setTab] = useState<Tab>(Tab.Notes);
  const [showBalance, setShowBalance] = useState(false); // Estado para mostrar/ocultar balance

  return (
    <div className="w-full">
      <div className="w-full space-y-8 lg:space-y-4 mb-12">
        <div className="flex justify-between w-full items-center">
          <h1 className="text-2xl lg:text-4xl font-bold pb-6 self-start">Enigma</h1>

          <div className="flex flex-col items-end gap-1">
            <span className="text-3xl lg:text-4xl font-bold">
              {showBalance ? balance.toString(16).slice(1, 6) : "****"}
            </span>

            <div className="flex items-center gap-1">
              <span className="text-base font-medium">My balance</span>
              <button onClick={() => setShowBalance(!showBalance)} className="text-primary">
                {showBalance ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>
        </div>

        <div className="gap-2 grid grid-cols-6">
          <button
            onClick={() => setTab(Tab.Notes)}
            className={cn(
              "h-9 px-1 text-sm border border-input hover:bg-accent bg-transparent rounded-lg border-primary flex items-center gap-1",
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
              "h-9 px-1 text-sm border border-input hover:bg-accent bg-transparent rounded-lg border-primary flex items-center gap-1",
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
              "h-9 px-1 text-sm border border-input hover:bg-accent bg-transparent rounded-lg border-primary flex items-center gap-1",
              {
                "bg-gradient-to-r from-[#9A5583] via-[#35269A] to-[#181972] text-white border-none":
                  tab === Tab.Receive,
              }
            )}
          >
            <Check className="h-4" /> Receive
          </button>
          <button
            onClick={() => setTab(Tab.Approve)}
            className={cn(
              "h-9 px-1 text-sm border border-input hover:bg-accent bg-transparent rounded-lg border-primary flex items-center gap-1",
              {
                "bg-gradient-to-r from-[#9A5583] via-[#35269A] to-[#181972] text-white border-none":
                  tab === Tab.Approve,
              }
            )}
          >
            <ArrowDown className="h-4" /> Approve
          </button>
        </div>
      </div>

      {tab === Tab.Notes && <Notes showBalance={showBalance} />}
      {tab === Tab.Send && <Transfer />}
      {tab === Tab.Receive && <Receive />}
      {tab === Tab.Approve && <Approve />}
    </div>
  );
}

export default Index;
