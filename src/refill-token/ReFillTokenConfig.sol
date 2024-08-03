// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ReFillTokenCommons.sol";

abstract contract ReFillTokenConfig is ReFillTokenCommons {
    // set reserve factor
    function setReserveFactor(uFixed reserveFactor) external onlyOwner {
        _reserveFactor = reserveFactor;
    }
}
