// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ReFillTokenStorage.sol";
import "../externals/aavev3/IPool.sol";
import "./IReFillToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract ReFillTokenGetters is IReFillToken, ReFillTokenStorage {
    function getAaveV3Data() external view returns (IERC20 underlying, IAToken aToken) {
        return (_underlying, _aToken);
    }
}