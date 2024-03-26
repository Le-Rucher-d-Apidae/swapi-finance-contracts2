# Swapi Smart Contracts
This repo contains all of the smart contracts used to run [Swapi](https://www.swapi.finance/).

## Deployed Contracts
none on mainnet.

## Used Contracts
Frontend uses Quickswap already deployed contracts

### Polygon Mumbai Testnet

Factory address: [0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32](https://mumbai.polygonscan.com/address/0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32)

Router address: [0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff](https://mumbai.polygonscan.com/address/0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32)

### Polygon Mainnet

Factory address (Quickswap): [0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32](https://polygonscan.com/address/0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32)

Router address: [0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff](https://polygonscan.com/address/0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff)

## Running
These contracts are compiled and deployed using [Hardhat](https://hardhat.org/). They can also be run using the Remix IDE.

To prepare the dev environment, run `yarn install`. To compile the contracts, run `yarn compile`. Yarn is available to install [here](https://classic.yarnpkg.com/en/docs/install/#debian-stable) if you need it.

## Accessing the ABI
If you need to use any of the contract ABIs, you can install this repo as an npm package with `npm install --dev @swapi-finance//contracts`. Then import the ABI like so: `import { abi as IUniswapV2PairABI } from '@swapi-finance//contracts/artifacts/contracts/swapi-core/interfaces/IUniswapV2Pair.sol/IUniswapV2Pair.json'`.

## Attribution
These contracts were adapted from these repos:
My Baker baguette-exchange : [contracts] (https://github.com/baguette-exchange/contracts)
Uniswap : [uniswap-v2-core](https://github.com/solidity-uniswap-lib/uniswap-v2-core), [uniswap-v2-periphery](https://github.com/solidity-uniswap-lib/uniswap-v2-core), and [uniswap-lib](https://github.com/solidity-uniswap-lib/uniswap-lib).

Synthetix's StakingRewards:
https://github.com/Synthetixio/synthetix/blob/v2.98.2/contracts/StakingRewards.sol
Tests:
https://github.com/Synthetixio/synthetix/blob/v2.98.2/test/contracts/StakingRewards.js

vittominacori (Vittorio Minacori)'sETH Token Recover:
https://vittominacori.github.io/eth-token-recover/
https://github.com/vittominacori/eth-token-recover
