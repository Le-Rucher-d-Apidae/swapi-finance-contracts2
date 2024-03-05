// require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers')
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

const defaultCompilerSettings = {
}
const compilerSettingsOpt200 = {
  optimizer: {
    enabled: true,
    runs: 200
  }
}
const compilerSettingsOpt1000 = {
  optimizer: {
    enabled: true,
    runs: 200
  }
}

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: '0.5.16',
        settings: defaultCompilerSettings
      },
      {
        version: '0.6.2',
        settings: defaultCompilerSettings
      },
      {
        version: '0.6.6',
        settings: compilerSettingsOpt200
      },
      // {
      //   version: '0.7.0'
      // },
      {
        version: '0.7.6',
        settings: defaultCompilerSettings
      },
      {
        version: '0.8.23',
        settings: compilerSettingsOpt1000
      }
    ]
  },
  networks: {
    hardhat: {
      gasPrice: 470000000000,
      chainId: 43112,
      initialDate: '2020-10-10'
    },
    avash: {
      url: 'http://localhost:9650/ext/bc/C/rpc',
      gasPrice: 470000000000,
      chainId: 43112,
      accounts: ['0x56289e99c94b6912bfc12adc093c9b51124f0dc54ac7a766b2bc5ccf558d8027']
    },
    fuji: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      gasPrice: 470000000000,
      chainId: 43113,
      accounts: []
    },
    mainnet: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      gasPrice: 470000000000,
      chainId: 43114,
      accounts: []
    }
  },
  paths: {
    // sources: "./contracts",
    sources: "./src/contracts",
    // tests: "./test",
    tests: "./hardhat-test",
    // cache: "./cache",
    cache: "./hardhat-cache",
    // artifacts: "./artifacts"
    artifacts: "./hardhat-artifacts"
  },
  mocha: {
    timeout: 40000
  }
}
