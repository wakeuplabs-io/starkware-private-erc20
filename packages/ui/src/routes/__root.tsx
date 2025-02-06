import { createRootRoute, Outlet } from "@tanstack/react-router";
import React from "react";

const TanStackRouterDevtools =
  import.meta.env.NODE_ENV === "production"
    ? () => null // Render nothing in production
    : React.lazy(() =>
      import("@tanstack/router-devtools").then((res) => ({
        default: res.TanStackRouterDevtools,
      }))
    );

export const Route = createRootRoute({
  component: () => (
    <div className="w-screen h-screen flex flex-col">
      <main>
        <Outlet />
      </main>
      <TanStackRouterDevtools />
    </div>
  ),
});
