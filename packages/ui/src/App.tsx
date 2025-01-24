import { RouterProvider } from "@tanstack/react-router";
import { router } from "@/shared/config/tanstackRouter";
import { WalletProvider } from "./shared/context/wallet-context";

function App() {
  return (
    <WalletProvider>
      <RouterProvider router={router} />
    </WalletProvider>
  );
}

export default App;
