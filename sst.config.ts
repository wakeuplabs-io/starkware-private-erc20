/// <reference path="./.sst/platform/config.d.ts" />

import "dotenv/config";

const PROJECT_NAME = "stkr-privado";

export default $config({
  app(input) {
    return {
      name: PROJECT_NAME,
      removal: input?.stage === "production" ? "retain" : "remove",
      protect: ["production"].includes(input?.stage),
      home: "aws",
    };
  },
  async run() {
    const vpc = new sst.aws.Vpc(`${PROJECT_NAME}-vpc`)

    const cluster = new sst.aws.Cluster(`${PROJECT_NAME}-cluster`, {
      vpc
    });
    const api = cluster.addService(`${PROJECT_NAME}-api`, {
      cpu: "1 vCPU",
      memory: "2 GB",
      image: {
        dockerfile: "packages/api/Dockerfile",
        context: "packages/api",
      },
      loadBalancer: {
        ports: [{ listen: "80/http" }],
      },
      dev: {
        command: "npm run dev",
      },
    });

    const ui = new sst.aws.StaticSite(`${PROJECT_NAME}-ui`, {
      path: "packages/ui",
      build: {
        command: "npm run build",
        output: "dist",
      },
      domain: "enigma.wakeuplabs.link",
      dev: {
        command: "npm run dev",
        directory: "packages/ui",
      },
      environment: {
        VITE_API_BASE_URL: api.url,
        VITE_RPC_URL: process.env.VITE_RPC_URL,
        VITE_DEPLOYMENT_ID: "starknet-goerli:1.0.0",
        VITE_EXPLORER_BASE_URL: "https://sepolia.voyager.online",
      },
      indexPage: "index.html",
      errorPage: "index.html",
      invalidation: {
        paths: "all",
        wait: true,
      },
    });

    return {
      ui: ui.url,
      api: api.url,
    };
  },
});
