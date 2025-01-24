import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  return (
    <div className="flex flex-1 items-center justify-center">
      <h3>Home Page</h3>
    </div>
  );
}
