// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../externals/aavev3/IPool.sol";
import "../externals/aavev3/IWETHGateway.sol";
import "./ReFillTokenConfig.sol";

contract ReFillToken is ReFillTokenConfig {
    constructor(
        string memory name,
        string memory symbol,
        IERC20 underlying,
        IAToken aToken,
        IPool aaveLendingPool,
        IWETHGateway wethGateway
    ) ERC20(name, symbol) Ownable(msg.sender) {
        _underlying = underlying;
        _aToken = aToken;
        _aaveLendingPool = aaveLendingPool;
        _wethGateway = wethGateway;
        // initial exchange rate
        _exchangeRate = uFixed.wrap(1e18);
        _reserveFactor = uFixed.wrap(1e18); // initialy all earnings are for protocols reserves, we can change it
    }

    function supply(uint amount) external payable nonReentrant {
        address suplier = msg.sender;
        _accrueInterest();
        // receive underlying token
        amount = _receiveUnderlying(suplier, amount);
        uint minTokens = div_(amount, _exchangeRate);
        // mint tokens
        _mint(suplier, minTokens);

        // supply in base protocol
        _supplyInAaveV3(amount);
        // update last supply time
        lastSupplyTime[suplier] = block.timestamp; 
        emit Supply(suplier, amount);
    }

    function _supplyInAaveV3(uint amount) private {
        // supply in Aave v3
        if (isNative()) {
            _wethGateway.depositETH{value: amount}(
                address(_aaveLendingPool),
                address(this),
                0
            );
        } else {
            _underlying.approve(address(_aaveLendingPool), amount);
            _aaveLendingPool.supply(
                address(_underlying),
                amount,
                address(this),
                0
            );
        }
    }

    function redeem(address to, uint nonce, uint ReFillTokenAmount, bytes calldata signature) external nonReentrant {
        // validate signature
        if (!_isValidSignature(owner(), keccak256(abi.encodePacked(to, ReFillTokenAmount, nonce)), signature)) {
            revert InvalidSigner();
        }
        _accrueInterest();
        address redeemer = msg.sender;
        uint amountRedeemable = balanceOf(redeemer);
        if (ReFillTokenAmount > amountRedeemable)
            ReFillTokenAmount = amountRedeemable;

        // burn tokens
        _burn(redeemer, ReFillTokenAmount);

        // underlying amount to redeem
        uint underlyingAmount = mul_(ReFillTokenAmount, _exchangeRate);

        if (to == address(0)) to = redeemer;

        // redeem in base protocol
        _redeemInAaveV3(underlyingAmount);
        // transfer underlying to to
        _transferUnderlying(payable(to), underlyingAmount);
        emit Redeem(redeemer, underlyingAmount);
    }

    function _redeemInAaveV3(uint underlyingAmount) private {
        // redeem in Aave v3
        if (isNative()) {
            _wethGateway.withdrawETH(
                address(_aaveLendingPool),
                underlyingAmount,
                address(this)
            );
        } else {
            _aaveLendingPool.withdraw(
                address(_underlying),
                underlyingAmount,
                address(this)
            );
        }
    }

    function removeReserves(address to, uint amount) external onlyOwner {
        _accrueInterest();
        if( amount > _totalReserves) revert InsufficientReserves();
        _totalReserves -= amount;
        // redeem in AaveV3 
        _redeemInAaveV3(amount);
        // transfer underlying to to
        _transferUnderlying(payable(to), amount);
        emit RemoveReserves(to, amount);
    }

    // function to remove ReFillToken from user if more than 14 days since last supply
    // the Token will be burned and update the reserves
    function removeUserTokens(address user, uint underlyingAmount) external onlyOwner {
        if( block.timestamp - lastSupplyTime[user] < 14 days) revert TooEarly();
        _accrueInterest();
        // calculate amount of tokens to burn
        uint amount = div_(underlyingAmount, _exchangeRate);
        if( amount > balanceOf(user)) revert InsufficientBalance();
        // burn the ReFillTokens
        _burn(user, amount);

        // update reserves
        _totalReserves += underlyingAmount;
        emit RemoveUserTokens(user, amount);
        
    }

}
