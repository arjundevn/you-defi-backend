require("@nomiclabs/hardhat-waffle");
require('dotenv').config({path:__dirname+'/.env'})

// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.
// require("./tasks/faucet");

// If you are using MetaMask, be sure to change the chainId to 1337
module.exports = {
  solidity: "0.8.3",
  defaultNetwork: "mumbai",
  networks: {
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/dqFqjhoWwfYYTCZoj__HMztYBmQd2BH7`,
      chainId: 80001,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`]
    }
  }
};