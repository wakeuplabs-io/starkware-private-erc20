import { Approve } from "@/components/approve";
import { Notes } from "@/components/notes";
import { Receive } from "@/components/receive";
import { TabButton } from "@/components/tab-button";
import { Transfer } from "@/components/transfer";
import { Button } from "@/components/ui/button";
import { useBalance } from "@/hooks/use-balance";
import { cn, formatTokenAmount } from "@/lib/utils";
import { createFileRoute } from "@tanstack/react-router";
import {
  ArrowDown,
  ArrowUpRight,
  Check,
  Eye,
  EyeClosed,
  List,
} from "lucide-react";
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
  const [show, setShow] = useState(false);

  return (
    <div className="w-full">
      <div className="w-full">
        <div className="flex justify-between items-center w-full mb-8 md:mb-2">
          <h1 className="bakbak-one-regular text-[36px] text-primary md:text-4xl">
            Enigma
          </h1>

          <div className="relative">
            <span className="bakbak-one-regular text-[40px] text-primary md:text-[56px] md:h-[78px] ">
              {show ? formatTokenAmount(balance) : "****"}
            </span>
            <div className="text-primary absolute bottom-0 right-0 translate-y-1/2 flex items-center gap-2 md:-bottom-2">
              <label
                htmlFor="toggle-balance"
                className="text-nowrap text-sm cursor-pointer md:text-base"
              >
                My balance
              </label>
              <Button
                id="toggle-balance"
                size="icon"
                variant="ghost"
                className="bg-transparent h-6 w-6"
                onClick={() => setShow(!show)}
              >
                {show ? <Eye className="h-8" /> : <EyeClosed className="w-8" />}
              </Button>
            </div>
          </div>
        </div>

        <div className="gap-2 grid grid-cols-4 max-w-md mb-8">
          <TabButton
            onClick={() => setTab(Tab.Notes)}
            active={tab == Tab.Notes}
            className="text-xs sm:text-base"
          >
            <List className="h-4 hidden sm:block " /> Notes
          </TabButton>
          <TabButton
            onClick={() => setTab(Tab.Send)}
            active={tab == Tab.Send}
            className="text-xs sm:text-base"
          >
            <ArrowUpRight className="h-4 hidden sm:block " /> Send
          </TabButton>
          <TabButton
            onClick={() => setTab(Tab.Approve)}
            active={tab == Tab.Approve}
            className="text-xs sm:text-base"
          >
            <Check className="h-4 hidden sm:block " /> Approve
          </TabButton>
          <TabButton
            onClick={() => setTab(Tab.Receive)}
            active={tab == Tab.Receive}
            className="text-xs sm:text-base"
          >
            <ArrowDown className="h-4 hidden sm:block " /> Receive
          </TabButton>
        </div>
      </div>

      {tab === Tab.Notes && <Notes show={show} />}
      {tab === Tab.Send && <Transfer />}
      {tab === Tab.Receive && <Receive />}
      {tab === Tab.Approve && <Approve />}
    </div>
  );
}

export default Index;
