import { RouterProvider } from "@tanstack/react-router";
import { router } from "@/shared/config/tanstackRouter";
import StarknetProvider from "./providers/starknet-provider";

function App() {
  return (
    <StarknetProvider>
      <RouterProvider router={router} />
    </StarknetProvider>
  );
}

export default App;
