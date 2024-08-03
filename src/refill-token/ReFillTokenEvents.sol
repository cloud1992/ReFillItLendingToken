// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IUnsignedFixed} from "../utils/UnsignedFixed.sol";

abstract contract ReFillTokenEvents is IUnsignedFixed {
    event Supply(address indexed account, uint amount);
    event AccrueInterest(uFixed exchangeRate, uint totalReserves);
    event Redeem(address redeemer, uint underlyingAmount);
    event RemoveReserves(address to, uint amount);
}
