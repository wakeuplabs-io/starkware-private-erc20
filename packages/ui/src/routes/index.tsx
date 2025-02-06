import "./home.css";
import { createFileRoute } from "@tanstack/react-router";
import AccountManager from "@/components/account-manager";
import NotesList from "@/components/notes-list";
import Transfer from "@/components/transfer";
import ConnectButton from "@/components/connect-button";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  return (
    <div className="home-container">
      <h1 className="home-title">Private-ERC20</h1>
      <ConnectButton />

      <div>
        <AccountManager />
        <NotesList />
        <Transfer />
      </div>
    </div>
  );
}

export default Index;
