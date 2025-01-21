import {
  Abi,
  Address,
  TransactionReceipt,
  WriteContractParameters,
} from "viem";
import { Clients } from "../types";

export async function executeAndWait<ABI = any>(
  clients: Clients,
  r:
    | {
        request: WriteContractParameters<ABI extends Abi ? ABI : any>;
        result: any;
      }
    | any,
  confirmations = 1
): Promise<TransactionReceipt> {
  const r1 = await clients.wallet.writeContract(r.request);

  return clients.public.waitForTransactionReceipt({
    hash: r1,
    confirmations: confirmations,
  });
}

export async function executeAndWaitDeploy(
  clients: Clients,
  hash: Address
): Promise<Address | null | undefined> {
  const receipt = await clients.public.waitForTransactionReceipt({
    hash,
    confirmations: 1,
  });

  return receipt.contractAddress;
}
