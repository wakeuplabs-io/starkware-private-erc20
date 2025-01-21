import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const foobarModule = buildModule("TokenModule", (m) => {
  const foobar = m.contract("Foobar", []);

  return { foobar };
});

export default foobarModule;
