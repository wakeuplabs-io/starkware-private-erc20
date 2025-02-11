import { Button } from "@/components/ui/button";
import { createFileRoute } from "@tanstack/react-router";
import { ArrowDown, ArrowUpRight, List } from "lucide-react";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  return (
    <div className="w-full">
      <div className="w-full space-y-4">
        <div className="flex justify-between w-full">
          <h1 className="text-4xl font-bold">ERC20 - Private</h1>
          <div className="relative">
            <div className="text-4xl font-bold">1217.12</div>
            <div className="absolute bottom-0 translate-y-full right-0">
              My balance
            </div>
          </div>
        </div>
        
        <div className="space-x-2">
          <Button variant="outline" size="sm" className="bg-transparent rounded-lg border-primary">
            <List /> Notes
          </Button>
          <Button variant="outline" size="sm" className="bg-transparent rounded-lg border-primary">
            <ArrowUpRight /> Send
          </Button>
          <Button variant="outline" size="sm" className="bg-transparent rounded-lg border-primary">
            <ArrowDown /> Receive
          </Button>
        </div>
      </div>

      {/* notes */}
      {/* send */}
      {/* transfer */}
    </div>
  );
}

export default Index;
