# ReFillToken

ReFillToken is a smart contract built on Ethereum that allows users to supply underlying tokens to the Aave v3 protocol, receive ReFill tokens in return, and later redeem these ReFill tokens to recover their underlying tokens.

## Contract Overview

The ReFillToken contract is implemented using Solidity and is compatible with the ERC-20 standard. This contract interacts with the Aave v3 protocol to deposit and withdraw underlying tokens, enabling users to provide liquidity while earning interest is assigned to the protocol's reserves.

### Key Functions

- **supply**: Allows users to deposit underlying tokens and receive ReFill tokens in proportion to the deposited amount and the current exchange rate.
- **redeem**: Enables users to redeem their ReFill tokens to recover underlying tokens along with accrued interest. Redemption can be done to the sender's address or a specified address.
- **removeReserves**: Only accessible by the contract owner. Allows the withdrawal of funds from the protocol's reserves, which have accumulated through the exchange rate mechanism.

### Interaction with Aave v3

The ReFillToken contract uses the `IPool` and `IWETHGateway` interfaces from Aave v3 to perform deposits and withdrawals of underlying tokens. Depending on whether the underlying token is native to the network (e.g., ETH) or not, the contract interacts with Aave differently:

- For native tokens, it uses the `IWETHGateway` to convert and deposit the corresponding value into the Aave protocol.
- For non-native tokens, it directly supplies and withdraws underlying tokens through `IPool`.

### Exchange Rate and Reserves

- The exchange rate (`_exchangeRate`) is a value that determines how many ReFill tokens are minted for each underlying token deposited.
- The contract maintains reserves (`_totalReserves`) that can be withdrawn using the `removeReserves` function by the contract owner.

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


