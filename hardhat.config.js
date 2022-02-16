require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  networks: {
    aurora_testnet: {
      url: "https://testnet.aurora.dev/",
      accounts: [
        'c946c09e166856cb02f88cb6a5a248ba9ed5b89c993eb8411ac79f1d84d2bc84',
        '20617f81e83594f2854f2687605710a0a834a31c0220537e64642a937caf3ecf',
      ],
      chainId: 1313161555,
      gasPrice: 120 * 1000000000
    }
  },
  solidity: {
    version: "0.8.11",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  }
}
