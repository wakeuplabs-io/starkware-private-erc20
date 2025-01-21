import { Abi } from "viem";
import { defineConfig } from "@wagmi/cli";

import foobar from "./artifacts/contracts/foobar/contract.sol/Foobar.json";

export default defineConfig({
  out: "./shared/abis/index.ts",
  contracts: [
    {
      name: "foobar",
      abi: foobar.abi as Abi,
    },
  ],
});
