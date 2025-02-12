import "./index.css";
import ProvidersWrapper from "@/providers/providers-wrapper.tsx";
import React from "react";
import ReactDOM from "react-dom/client";
import { router } from "@/shared/config/tanstackRouter";
import StarknetProvider from "./providers/starknet-provider.tsx";
import { RouterProvider } from "@tanstack/react-router";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <ProvidersWrapper>
    <StarknetProvider>
      <RouterProvider router={router} />
    </StarknetProvider>
    </ProvidersWrapper>
  </React.StrictMode>
);
