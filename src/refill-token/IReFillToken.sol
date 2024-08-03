// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../utils/UnsignedFixed.sol";
import "../externals/aavev3/IPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
interface IReFillToken is IUnsignedFixed {
    function supply(uint amount) external payable;

    function redeem(address to, uint nonce, uint ReFillTokenAmount, bytes calldata signature) external;

    function isNative() external view returns (bool);

    function setReserveFactor(uFixed reserveFactor) external; // onlyOwner

    function removeReserves(address to, uint amount) external; // onlyOwner

    function getAaveV3Data() external view returns (IERC20 underlying, IAToken aToken);
}
