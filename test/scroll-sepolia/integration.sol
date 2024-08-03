// FOUNDRY_PROFILE=integration forge test -vv --optimize
// FOUNDRY_PROFILE=integration forge test -vv --optimize --match-test testRedeem

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../../deploy/DeployScript.s.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract CounterTest is Test, DeployScript {
    using MessageHashUtils for bytes32;
    constructor() DeployScript(Network.SCROLL_SEPOLIA) {}
    address bob = address(1);

    function setUp() public {
        (address deployer,) = _getDeployer();
        vm.startPrank(deployer);
        _deployContract();
        vm.stopPrank();
        
    }

    // Basic test to verify supply function
    // supply native token
    function testSupply() public {
        console.log("supply=============");
        deal(bob, 100 ether);
        // get aaveV3 data
        (, IAToken aToken) = reFillTokenNative.getAaveV3Data();
        uint supplyInAaveV3Before = aToken.scaledBalanceOf(address(reFillTokenNative));
        uint amoutToSupply = 1 ether;
        vm.prank(bob);
        reFillTokenNative.supply{value:amoutToSupply}(amoutToSupply);
        
        uint supplyInAaveV3After = aToken.scaledBalanceOf(address(reFillTokenNative));

        assertEq(supplyInAaveV3After, supplyInAaveV3Before + amoutToSupply);
       
        console.log("End supply ===============");

    }

    // Basic test to verify redeem function
    // supply and redeem USDC token
    function testRedeem() public {
        console.log("start redeem test=============");
        deal(bob, 10 ether);
        
        // get aaveV3 data
        (IERC20 underlyingUSDC, IAToken aToken) = reFillTokenUSDC.getAaveV3Data();
        // deal USDC
        deal(address(underlyingUSDC), bob, 10000_000_000);

        uint supplyInAaveV3Before = aToken.scaledBalanceOf(address(reFillTokenUSDC));
        uint amoutToSupply = 10_000_000;
        vm.startPrank(bob);
        // approve supply amount
        underlyingUSDC.approve(address(reFillTokenUSDC), amoutToSupply); 
        reFillTokenUSDC.supply{value:amoutToSupply}(amoutToSupply);
        vm.stopPrank();    
        uint amoutToRedeem = 10_000_000;
        
        uint nonce = 1;
        // sign the message by the owner of the contract (deployer)
        bytes memory signature = signMessage(bob, amoutToRedeem, nonce);
        vm.prank(bob);
        reFillTokenUSDC.redeem(bob, nonce, amoutToRedeem, signature);
        uint supplyInAaveV3After = aToken.scaledBalanceOf(address(reFillTokenUSDC));
        uint balanceBobAfter = address(bob).balance;
        
        assertEq(supplyInAaveV3After, supplyInAaveV3Before);
        console.log("End redeem ===============");
    }

    function signMessage(address to, uint amount, uint nonce) private  returns (bytes memory) {
       (address deployer, uint deployerPrivateKey) = _getDeployer();
        bytes32 digest = keccak256(abi.encodePacked(to, amount, nonce)).toEthSignedMessageHash();
        vm.startPrank(deployer);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(deployerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v); // note the order here is different from line above.
        vm.stopPrank();
        return signature;
    }   
    

    function _getDeployer() private view returns (address deployer, uint deployerPrivateKey) {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        deployer = vm.addr(deployerPrivateKey);
    }
}
