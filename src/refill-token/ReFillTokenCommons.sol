// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ReFillTokenEvents.sol";
import "./ReFillTokenConstants.sol";
import "./ReFillTokenErrors.sol";
import "./ReFillTokenGetters.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

abstract contract ReFillTokenCommons is
    ReFillTokenGetters,
    ReFillTokenEvents,
    ReFillTokenConstants,
    ReFillTokenErrors,
    ERC20
{
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // function to receive underlying token ERC20
    function _receiveUnderlying(
        address from,
        uint amount
    ) internal virtual returns (uint) {
        uint balanceBefore = _underlying.balanceOf(address(this));
        _underlying.safeTransferFrom(from, address(this), amount);
        amount = _underlying.balanceOf(address(this)) - balanceBefore;

        return amount;
    }

    // function to transfer underlying token ERC20
    function _transferUnderlying(
        address payable to,
        uint amount
    ) internal virtual {
        _underlying.safeTransfer(to, amount);
    }

    
    function isNative()
        public
        pure
        virtual
        override(IReFillToken)
        returns (bool)
    {
        return false;
    }

    // accrue interest
    // this function is called before any action to update the exchange rate and total reserves
    function _accrueInterest() internal {
        if (_accrualBlockNumber == block.number) return;
        uint liquidyInAaveV3 = _liquidityInAaveV3();

        uint newTotalReserves = _totalReserves;

        // total supply (total amount of tokens minted)
        uint totalSupply = totalSupply();
        // old total liquidity, calculated with old exchange rate
        uint oldTotalLiquidity = mul_(totalSupply, _exchangeRate); // value of underlying token

        
        uint newTotalLiquidty = liquidyInAaveV3 - newTotalReserves;

        if ( newTotalLiquidty > oldTotalLiquidity) {
            uint extraEarnings;
            unchecked {
                extraEarnings = newTotalLiquidty - oldTotalLiquidity;
            }
            uint deltaReserves = mul_(extraEarnings, _reserveFactor);
            unchecked {
                newTotalReserves += deltaReserves;
                newTotalLiquidty -= deltaReserves;
            }
        }

        // recompute exchange rate
        if (newTotalLiquidty > 0 && totalSupply > 0) {
            _exchangeRate = div_(newTotalLiquidty, totalSupply);
        }

        _totalReserves = newTotalReserves;
        _accrualBlockNumber = block.number;
        // emit event
        emit AccrueInterest(_exchangeRate, newTotalReserves);
    }

    function _liquidityInAaveV3()
        internal
        view
        returns (uint liquidity)
    {
        liquidity = _aToken.balanceOf(address(this));
    }

    // internal function to verify signature, here we use Elliptic Curve Digital Signature Algorithm (ECDSA) library
    // from OpenZeppeling
    function _isValidSignature(address signer, bytes32 hash, bytes memory signature) internal pure returns (bool) {
        require(signer != address(0), "Missing Signer Address");
        bytes32 signedHash = hash.toEthSignedMessageHash();
        return signedHash.recover(signature) == signer;
    }
}
