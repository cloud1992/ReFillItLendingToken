// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ReFillTokenEvents.sol";
import "./ReFillTokenConstants.sol";
import "./ReFillTokenErrors.sol";
import "./ReFillTokenGetters.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract ReFillTokenCommons is
    ReFillTokenGetters,
    ReFillTokenEvents,
    ReFillTokenConstants,
    ReFillTokenErrors,
    ERC20
{
    using SafeERC20 for IERC20;

    function _receiveUnderlying(
        address from,
        uint amount
    ) internal virtual returns (uint) {
        uint balanceBefore = _underlying.balanceOf(address(this));
        _underlying.safeTransferFrom(from, address(this), amount);
        amount = _underlying.balanceOf(address(this)) - balanceBefore;

        return amount;
    }

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


     function _getMessageHash(
        address _to,
        uint256 _amount,
        uint256 _nonce
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _nonce));
    }

    function _getEthSignedMessageHash(bytes32 _messageHash)
        private
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    function _recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) private pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _splitSignature(bytes memory sig)
        private
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    function _verify(
        address signer,
        address to,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) internal pure returns (bool) {
        bytes32 messageHash = _getMessageHash(to, amount, nonce);
        bytes32 ethSignedMessageHash = _getEthSignedMessageHash(messageHash);
        return _recoverSigner(ethSignedMessageHash, signature) == signer;
    }
}
