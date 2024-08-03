// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../externals/aavev3/IPool.sol";
import "../externals/aavev3/IWETHGateway.sol";
import {UnsignedFixed} from "../utils/UnsignedFixed.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

abstract contract ReFillTokenStorage is
    Ownable,
    UnsignedFixed,
    ReentrancyGuard
{
    uint public _accrualBlockNumber;
    // last time a user made supply
    mapping(address => uint) public lastSupplyTime;

    // total protocol reserves
    uint public _totalReserves;

    // referve factor
    uFixed public _reserveFactor;

    // exchange rate
    uFixed public _exchangeRate;

    // underlying token
    IERC20 public _underlying;

    // Aave V3 variables
    IAToken internal _aToken;
    IPool internal _aaveLendingPool;
    IWETHGateway internal _wethGateway;
}
