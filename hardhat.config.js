require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

const { PRIVATE_KEY, ETHERSCAN_API } = process.env;

// This is a sample Hardhat task. To learn how to create your own go to
console.log('[Hardhat config]', `This is a sample Hardhat task. To learn how to create your own go to`);
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  defaultNetwork: "testnet",
  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/3b97bdd6ecb241a38f8b7f9250f898a2`,
      accounts: [PRIVATE_KEY]
    },
    goerli: {
      url: `https://goerli.infura.io/v3/3b97bdd6ecb241a38f8b7f9250f898a2`,
      accounts: [PRIVATE_KEY]
    },
    mumbai: {
      url: `https://rpc-mumbai.maticvigil.com/`,
      accounts: [PRIVATE_KEY]
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/3b97bdd6ecb241a38f8b7f9250f898a2`,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API,
  },
};
