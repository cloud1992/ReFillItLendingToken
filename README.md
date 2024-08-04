# ReFillToken

ReFillToken is a smart contract solution designed to incentivize environmentally-friendly behavior by allowing users to deposit underlying tokens into the Aave v3 protocol, receive ReFill tokens in return, and later redeem these tokens to recover their underlying assets. This solution is compatible with any Ethereum Virtual Machine (EVM) chain, and for this project, we are focusing on the Scroll blockchain as part of our participation in a Hackathon sponsored by Scroll.

## Contract Overview

ReFillToken is implemented through two separate contracts:

- **ReFillTokenNative**: Designed for native tokens (e.g., ETH).
- **ReFillToken**: Designed for non-native tokens such as stablecoins (e.g., USDC).

### Supported Assets

ReFillToken supports the following types of underlying assets:
- **Native Token (ETH)**: Managed through the `ReFillTokenNative` contract.
- **USDC (USD Coin)**: Managed through the `ReFillToken` contract.

## Deployed Contracts on Scroll-Sepolia

- **ReFillTokenNative (ETH)**: [0xa3f7bf5b0fa93176c260bba57cee85525de2baf4](https://sepolia.scrollscan.com/address/0xa3f7bf5b0fa93176c260bba57cee85525de2baf4)
- **ReFillTokenUSDC**: [0x25a1df485cfbb93117f12fc673d87d1cddeb845a](https://sepolia.scrollscan.com/address/0x25a1df485cfbb93117f12fc673d87d1cddeb845a)

### Key Functions

- **supply**: Allows users to deposit underlying tokens (ETH or USDC) and receive ReFill tokens in proportion to the deposited amount and the current exchange rate.
- **redeem**: Enables users to redeem their ReFill tokens to recover underlying tokens. The accrued interest from these tokens is allocated to the protocol reserves.
- **removeReserves**: Only accessible by the contract owner. Allows the withdrawal of funds from the protocol's reserves.

### Interaction with Aave v3

The ReFillToken contracts interact with the Aave v3 protocol for depositing and withdrawing underlying tokens:

- **ReFillTokenNative**: Uses the `IWETHGateway` to convert and deposit native tokens (ETH) into Aave.
- **ReFillToken**: Directly supplies and withdraws non-native tokens (USDC) through the `IPool` interface.

### Exchange Rate and Reserves

- The exchange rate (`_exchangeRate`) is used to determine how many ReFill tokens are minted for each underlying token deposited.
- The contracts maintain reserves (`_totalReserves`), which can be withdrawn by the contract owner using the `removeReserves` function.


## Installation and Usage

### Prerequisites

- [Node.js](https://nodejs.org/)
- [Hardhat](https://hardhat.org/)
- An Ethereum account with funds on the desired network (Mainnet, Scroll, etc.)

### Installation

1. Clone this repository:
    ```bash
    git clone https://github.com/yourusername/ReFillToken.git
    cd ReFillToken
    ```

2. Install project dependencies:
    ```bash
    npm install
    ```

### Contract Deployment

You can deploy the contract using scripts in folder scripts/deploy:

```bash
bash scripts/deploy/Deploy.sh --network scroll_sepolia

```

### Test
You can run some basic test in folder test/scroll-sepolia

```shell
$ FOUNDRY_PROFILE=integration forge test -vv --optimize
```



### Deploy in Anvil
There is a script to start anvil forking an blockchain and deploy on it

```shell
$ bash scripts/deploy/startAnvilChains.sh scroll_sepolia
$ bash scripts/deploy/DeployAnvil.sh --fork scroll_sepolia
```


