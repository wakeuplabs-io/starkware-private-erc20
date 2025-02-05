/// <reference path="./.sst/platform/config.d.ts" />

import "dotenv/config";

const PROJECT_NAME = "starkware-privado-erc20";

export default $config({
  app(input) {
    return {
      name: "starkware-privado",
      removal: input?.stage === "production" ? "retain" : "remove",
      protect: ["production"].includes(input?.stage),
      home: "aws",
    };
  },
  async run() {

    const cluster = new sst.aws.Cluster(`${PROJECT_NAME}-cluster`, {
      vpc: {
        id: process.env.VPC_ID,
        securityGroups: process.env.SECURITY_GROUPS.split(","),
        loadBalancerSubnets: process.env.SUBNETS.split(","),
        containerSubnets: process.env.SUBNETS.split(","),
        cloudmapNamespaceId: process.env.CLOUDMAP_NAMESPACE_ID,
        cloudmapNamespaceName: process.env.CLOUDMAP_NAMESPACE_NAME,
      }
    });
    const api = cluster.addService(`${PROJECT_NAME}-api`, {
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
      dev: {
        command: "npm run dev",
        directory: "packages/ui",
      },
      environment: {
        VITE_API_BASE_URL: api.url,
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
