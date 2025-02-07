/// <reference path="./.sst/platform/config.d.ts" />

import "dotenv/config";

const PROJECT_NAME = "starkware-privado-erc20";

const VPC_ID="vpc-052399c6758e34ed7"
const SUBNETS=["subnet-07b124263b35ed980", "subnet-03f70fcf113aba9ec"]
const SECURITY_GROUPS=["sg-0332127c082be783a"]
const CLOUDMAP_NAMESPACE_ID="ns-7srnyibfqdcwxlsk"
const CLOUDMAP_NAMESPACE_NAME="staging"

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
        id: VPC_ID,
        securityGroups: SECURITY_GROUPS,
        loadBalancerSubnets: SUBNETS,
        containerSubnets: SUBNETS,
        cloudmapNamespaceId: CLOUDMAP_NAMESPACE_ID,
        cloudmapNamespaceName: CLOUDMAP_NAMESPACE_NAME,
      }
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
