import { Address } from "viem";

import { Clients, getClient } from "./client";

// Ignition
import { ignition } from "hardhat";
import tokenModule from "../../ignition/foobar";

/**
 * Interface for the result of a token deployment.
 */
interface DeployResult {
  address: Address;
}

/**
 * Deploys token contract using the Ignition deployment framework.
 *
 * @returns A promise that resolves with the address of the deployed token.
 * @throws If the deployment fails.
 */
export const deployToken = async (): Promise<Address> => {
  try {
    const { foobar } = await ignition.deploy(tokenModule);
    if (!foobar) throw new Error("Token deployment failed.");
    return (foobar as DeployResult).address;
  } catch (error) {
    console.error("Error deploying token:", error);
    throw error;
  }
};

/**
 * Type representing the test environment for token interactions.
 */
export type TestEnv = {
  token: Address;
  clients: Clients;
};

/**
 * Generates a test environment for token interactions.
 *
 * @returns A promise that resolves with a TestEnv object containing the token address, clients, and service.
 * @throws If the test environment setup fails.
 */
export const generateTestEnv = async (): Promise<TestEnv> => {
  try {
    const clients = await getClient();

    const token = await deployToken();

    return {
      token,
      clients,
    };
  } catch (error) {
    console.error("Error generating test environment:", error);
    throw error;
  }
};
