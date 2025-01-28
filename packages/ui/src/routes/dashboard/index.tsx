import Transfer from "@/components/transfer/transfer";
import Balance from "@/components/balance/balance";
import "./dashboard.css";
import { createFileRoute } from "@tanstack/react-router";
import AccountManager from "@/components/account-manager";


export const Route = createFileRoute("/dashboard/")({
  component: Dashboard,
});


function Dashboard () {
  return (
    <div className="dashboard-container">
      <AccountManager />
      <Transfer/>
    </div>
  );
};

export default Dashboard;
