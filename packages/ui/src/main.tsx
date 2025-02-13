import "./index.css";
import React from "react";
import ReactDOM from "react-dom/client";
import { ProvidersWrapper } from "@/shared/providers/providers-wrapper.tsx";
import { StarknetProvider } from "@/shared/providers/starknet-provider.tsx";
import { router } from "@/shared/config/router.ts";
import { RouterProvider } from "@tanstack/react-router";
import { Toaster } from "@/components/ui/toaster.tsx";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <ProvidersWrapper>
      <StarknetProvider>
        <RouterProvider router={router} />
        <Toaster />
      </StarknetProvider>
    </ProvidersWrapper>
  </React.StrictMode>
);
