import Approval from "@/components/approve/approval";
import Transfer from "@/components/transfer/transfer";
import Balance from "@/components/balance/balance";
import "./dashboard.css";
import { createFileRoute } from "@tanstack/react-router";


export const Route = createFileRoute("/dashboard/")({
  component: Dashboard,
});


function Dashboard () {
  return (
    <div className="dashboard-container">
      <Balance />
      <Transfer/>
    </div>
  );
};

export default Dashboard;
