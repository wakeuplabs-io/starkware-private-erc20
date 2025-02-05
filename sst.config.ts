/// <reference path="./.sst/platform/config.d.ts" />

const PROJECT_NAME = "starkware-privado";

export default $config({
  app(input) {
    return {
      name: "starkware-private-erc20",
      removal: input?.stage === "production" ? "retain" : "remove",
      protect: ["production"].includes(input?.stage),
      home: "aws",
    };
  },
  async run() {
    const vpc = new sst.aws.Vpc(`${PROJECT_NAME}-vpc`);

    const cluster = new sst.aws.Cluster(`${PROJECT_NAME}-cluster`, { vpc });
    const api = cluster.addService(`${PROJECT_NAME}-api`, {
      image: {
        dockerfile: "packages/api/Dockerfile",
        context: "packages/api",
      },
      loadBalancer: {
        ports: [{ listen: "80/http" }],
      },
      dev: {
        command: "node --watch index.mjs",
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
        VITE_API_URL: api.url,
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
