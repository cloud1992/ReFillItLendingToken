// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract Config {
    // enum Markets
    enum Markets {
        ETH,
        USDC
    }

    enum Network {
        SCROLL_SEPOLIA,
        ARBITRUM_SEPOLIA
    }

    // struct MarketData
    struct MarketData {
        bool isNative;
        string name;
        string symbol;
        address underlying;
        // Aave V3 variables
        address aToken;
    }

    address internal _lendingPool;
    address internal _wethGateway;

    Markets[] internal _aaveV3Markets;

    // Markets => MarketData
    mapping(Markets => MarketData) public _aaveV3InitMarkets;

    constructor(Network network) {
        if (network == Network.SCROLL_SEPOLIA) {
            _initializeScrollSepoliaAaveV3();
        } else if (network == Network.ARBITRUM_SEPOLIA) {
            _initializeArbitrumSepoliaAaveV3();
        }
    }

    function _initializeScrollSepoliaAaveV3() private {
        _aaveV3Markets.push(Markets.ETH);
        _aaveV3InitMarkets[Markets.ETH] = MarketData(
            true,
            "ReFill-Token-ETH",
            "RFAV3ETH",
            0xb123dCe044EdF0a755505d9623Fba16C0F41cae9,
            0x9E8CEC4F2F4596141B62e88966D7167E9db555aD
        );
        _aaveV3Markets.push(Markets.USDC);
        _aaveV3InitMarkets[Markets.USDC] = MarketData(
            false,
            "ReFill-Token-USDC",
            "RFAV3USDC",
            0x2C9678042D52B97D27f2bD2947F7111d93F3dD0D,
            0x6E4A1BcBd3C3038e6957207cadC1A17092DC7ba3
        );

        _lendingPool = 0x48914C788295b5db23aF2b5F0B3BE775C4eA9440;
        _wethGateway = 0x57ce905CfD7f986A929A26b006f797d181dB706e;
    }

    function _initializeArbitrumSepoliaAaveV3() private {
        _aaveV3Markets.push(Markets.ETH);
        _aaveV3InitMarkets[Markets.ETH] = MarketData(
            true,
            "ReFill-Token-ETH",
            "RFAV3ETH",
            0x1dF462e2712496373A347f8ad10802a5E95f053D,
            0xf5f17EbE81E516Dc7cB38D61908EC252F150CE60
        );
        _aaveV3Markets.push(Markets.USDC);
        _aaveV3InitMarkets[Markets.USDC] = MarketData(
            false,
            "ReFill-Token-USDC",
            "RFAV3USDC",
            0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d,
            0x1d2a0E5EC8E5bBDCA5CB219e649B565d8e5c3360
        );

        _lendingPool = 0xBfC91D59fdAA134A4ED45f7B584cAf96D7792Eff;
        _wethGateway = 0x20040a64612555042335926d72B4E5F667a67fA1;
    }
}
