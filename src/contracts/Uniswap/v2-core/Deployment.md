# Deployment

## Contracts

### Factory
UniswapV2FactoryTest factory deployment on testnet: provide address for fees "_feeToSetter"
constructor(address _feeToSetter) public

Update factory address in swapi-finance-sdk/src/constants.ts
Call INIT_CODE_HASH_MAP factory getter and update its value in:
- swapi-finance/contracts/contracts/Uniswap/v2-periphery/libraries/UniswapV2Library.sol : function pairFor
- swapi-finance-sdk/src/constants.ts

### Router
router deployment: use factory address and wrapped currency (AVAX, MATIC, WETH/...) address
constructor(address _factory, address _WETH) public

Update router address in swapi-finance/interface/src/constants/index.ts


Adding a Pool

Requires creating a pair (automatically created when a pool is created) and a pool by calling the factory's createPair and createPool functions.
Easiest way to do this is to use the frontend to create a pool and then copy the pair liquidity  addresse from the pool creation tx (or call getPair on the Factory).

Adding a staking Pool

Requires an existing Pool. Create one before then deploy a StakingRewards contract :
 StakingRewards( rewardTokenAddress, pairAddress )


Rewarding

Duration must be set first (setRewardsDuration) before using notifyRewardAmount (once notifyRewardAmount is called, the rewards will be distributed over the duration period and cannot be changed until the previous duration is over), then immediatly call notifyRewardAmount to start the rewards distribution.
Default duration is 1 day.
Duration is in seconds (1 day = 60 * 60 * 24 = 86400 seconds)

When setting reward the contract must already have at least enough reward tokens to cover the duration of the rewards (else notifyRewardAmount() will revert).
Once notifyRewardAmount() is called, the rewards will be distributed over the duration period and cannot be changed until the previous duration is over.

- Send enough reward tokens to the StakingRewards contract
- Call setRewardsDuration
- Call notifyRewardAmount

- notifyRewardAmountcan be called anytime to increase or decrease the rewards for the current  duration set (or remaining).