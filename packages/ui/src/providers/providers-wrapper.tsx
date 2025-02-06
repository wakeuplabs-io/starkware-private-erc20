import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import React from "react";

const queryClient = new QueryClient();

interface ProvidersWrapperProps {
  children: React.ReactNode;
}

export default function ProvidersWrapper({ children }: ProvidersWrapperProps) {
  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}
