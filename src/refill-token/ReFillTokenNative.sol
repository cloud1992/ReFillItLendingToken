// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ReFillToken.sol";

contract ReFillTokenNative is ReFillToken {
    constructor(
        string memory name,
        string memory symbol,
        IERC20 underlying,
        IAToken aToken,
        IPool aaveLendingPool,
        IWETHGateway wethGateway
    )
        ReFillToken(
            name,
            symbol,
            underlying,
            aToken,
            aaveLendingPool,
            wethGateway
        )
    {}

    receive() external payable {}

    function _transferUnderlying(
        address payable to,
        uint amount
    ) internal override {
        to.transfer(amount);
    }

    function _receiveUnderlying(
        address /*from*/,
        uint amount
    ) internal pure override returns (uint) {
        return amount;
    }

    function isNative()
        public
        pure
        override(ReFillTokenCommons)
        returns (bool)
    {
        return true;
    }
}
