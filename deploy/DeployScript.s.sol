// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Config.sol";
import "../src/refill-token/ReFillToken.sol";
import "../src/refill-token/ReFillTokenNative.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployScript is Script, Config {
    ReFillTokenNative public reFillTokenNative;
    ReFillToken public reFillTokenUSDC; 
    constructor(Network network) Config(network) {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer: ", deployer);
        vm.startBroadcast(deployerPrivateKey);
        _deployContract();
        vm.stopBroadcast();
    }

    function _deployContract() internal {
        console.log("Deploying contract...");
        for (uint i; i < _aaveV3Markets.length; ++i) {
            Markets market = _aaveV3Markets[i];
            MarketData memory marketData = _aaveV3InitMarkets[market];
            if (marketData.isNative) {
                reFillTokenNative = new ReFillTokenNative(
                    marketData.name,
                    marketData.symbol,
                    IERC20(marketData.underlying),
                    IAToken(marketData.aToken),
                    IPool(_lendingPool),
                    IWETHGateway(_wethGateway)
                );
                console.log(
                    "ReFillTokenNative deployed at: ",
                    address(reFillTokenNative)
                );
            } else {
                reFillTokenUSDC = new ReFillToken(
                    marketData.name,
                    marketData.symbol,
                    IERC20(marketData.underlying),
                    IAToken(marketData.aToken),
                    IPool(_lendingPool),
                    IWETHGateway(_wethGateway)
                );
                console.log(
                    "reFillToken deployed at: ",
                    address(reFillTokenUSDC)
                );
            }
        }
    }
}

contract DeployScrollSepolia is DeployScript {
    constructor() DeployScript(Network.SCROLL_SEPOLIA) {}
}

contract DeployArbitrumSepolia is DeployScript {
    constructor() DeployScript(Network.ARBITRUM_SEPOLIA) {}
}
