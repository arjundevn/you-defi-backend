// This is a script for deploying your contracts. You can adapt it to deploy

const { artifacts } = require("hardhat");
const { ethers} = require("hardhat");

// yours, or create new ones.
async function main() {

  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const YouDefi = await ethers.getContractFactory("YouDefi");
  const youDefi = await YouDefi.deploy();
  await youDefi.deployed();
  console.log("\YouDefi address:", youDefi.address);

// function saveFrontendFiles() {
  const fs = require("fs");
  const deployedContractsDir = __dirname + "/../deployedContracts";

  if (!fs.existsSync(deployedContractsDir)) {
    fs.mkdirSync(deployedContractsDir);
  }

  fs.writeFileSync(
    deployedContractsDir + "/contract-address.json",
    JSON.stringify({ YouDefi: youDefi.address }, undefined, 2),
  //   JSON.stringify({ MultiSig: multiSig.address }, undefined, 2)
  );
  
  // const TokenArtifact = artifacts.readArtifactSync("Token");
  // const MultiSigArtifact = artifacts.readArtifactSync("MultiSig");
  
  // fs.writeFileSync(
  //   contractsDir + "/Token.json",
  //   JSON.stringify(TokenArtifact, null, 2)
  // );

  // fs.writeFileSync(
  //   contractsDir + "/MultiSig.json",
  //   JSON.stringify(MultiSigArtifact, null, 2)
  // );
  }

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
