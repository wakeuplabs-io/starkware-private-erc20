import { RpcProvider } from "starknet";

export const provider = new RpcProvider({ nodeUrl: import.meta.env.VITE_RPC_URL });