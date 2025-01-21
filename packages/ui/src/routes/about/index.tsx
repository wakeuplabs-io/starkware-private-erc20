import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/about/")({
  component: About,
});

function About() {
  return (
    <div className="flex flex-1 items-center justify-center">
      <h3>About Page</h3>
    </div>
  );
}
