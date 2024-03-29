// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {GlpPositionManager} from "src/GlpPositionManager.sol";
import {IGlpManager} from "gmx/IGlpManager.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IRewardRouter} from "gmx/IRewardRouter.sol";
import {IRewardRouterV2} from "gmx/IRewardRouterV2.sol";
import {PriceUtils} from "src/PriceUtils.sol";

contract GlpPositionManagerTest is Test {
  address mockAddress = address(0);
  GlpPositionManager glpPositionManager;
  uint256 usdcAmount = 2*10**6;

  function setUp() public {
    glpPositionManager = new GlpPositionManager();

    glpPositionManager.initialize(
        mockAddress,
        mockAddress,
        mockAddress,
        mockAddress,
        mockAddress,
        mockAddress,
        mockAddress,
        mockAddress,
        mockAddress,
        mockAddress
    );

    vm.mockCall(
        mockAddress,
        abi.encodeCall(PriceUtils.glpPrice, ()),
        abi.encode(1*10**6)
    );

    vm.mockCall(
        mockAddress,
        abi.encodeWithSelector(ERC20.transferFrom.selector),
        abi.encode(true)
    );

    vm.mockCall(
        mockAddress,
        abi.encodeWithSelector(ERC20.approve.selector),
        abi.encode(true)
    );

    vm.mockCall(
        mockAddress,
        abi.encodeWithSelector(IRewardRouterV2.mintAndStakeGlp.selector),
        abi.encode(1996*10**15)
    );
  }

  function testCanBuyPosition() public {
    uint256 expectedGlpAmount = 1996*10**15;
    uint256 expectedPositionWorth = 1996000;
    int256 expectedPnl = -4000;
    uint256 tokenAmount = glpPositionManager.buy(usdcAmount);
    assertEq(glpPositionManager.costBasis(), usdcAmount);
    assertEq(tokenAmount, expectedGlpAmount);
    assertEq(glpPositionManager.positionWorth(), expectedPositionWorth);
    assertEq(glpPositionManager.pnl(), expectedPnl);
  }
} 
