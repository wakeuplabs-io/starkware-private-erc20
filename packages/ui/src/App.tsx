import { router } from "@/shared/config/tanstackRouter";
import { RouterProvider } from "@tanstack/react-router";

function App() {
  return <RouterProvider router={router} />;
}

export default App;
