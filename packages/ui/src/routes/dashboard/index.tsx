import Transfer from "@/components/transfer";
import { createFileRoute } from "@tanstack/react-router";
import NotesList from "@/components/notes-list";
import "./dashboard.css";
import AccountManager from "@/components/account-manager";


export const Route = createFileRoute("/dashboard/")({
  component: Dashboard,
});


function Dashboard () {
  return (
    <div className="dashboard-container">
      <AccountManager />
      <NotesList />
      <Transfer/>
    </div>
  );
}

export default Dashboard;
