import Transfer from "@/components/transfer";
import { createFileRoute } from "@tanstack/react-router";
import AccountManager from "@/components/account-manager";
import NotesList from "@/components/notes-list";
import "./dashboard.css";
import acir from "@/../public/circuits/transfer.json";


export const Route = createFileRoute("/dashboard/")({
  component: Dashboard,
});


function Dashboard () {
  return (
    <div className="dashboard-container">
      <AccountManager />
      <NotesList />
      <Transfer acir={acir}/>
    </div>
  );
}

export default Dashboard;
