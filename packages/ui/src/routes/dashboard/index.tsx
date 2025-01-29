// import Transfer from "@/components/transfer/transfer";
import "./dashboard.css";
import { createFileRoute } from "@tanstack/react-router";
import AccountManager from "@/components/account-manager";
import NotesList from "@/components/notes-list";


export const Route = createFileRoute("/dashboard/")({
  component: Dashboard,
});


function Dashboard () {
  return (
    <div className="dashboard-container">
      <AccountManager />
      <NotesList />
      {/* <Transfer/> */}
    </div>
  );
}

export default Dashboard;
