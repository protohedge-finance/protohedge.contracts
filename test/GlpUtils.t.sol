// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {GlpUtils} from "src/GlpUtils.sol";
import {IVaultReader} from "gmx/IVaultReader.sol";
import {GlpTokenAllocation} from "src/GlpTokenAllocation.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract GlpUtilsTest is Test {
  GlpUtils private glpUtils;
  address private mockAddress = address(0);
  uint256 expectedPoolAmount;
  uint256 expectedUsdgAmount;
  uint256 expectedWeight;
  address[] private tokens = new address[](2);
  address usdcAddress = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
  address ethAddress = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

  function setUp() public {
    tokens[0] = usdcAddress;
    tokens[1] = ethAddress;

    uint256[] memory mockResponse = new uint256[](28);
    mockResponse[0] = 114197608576723;
    mockResponse[1] = 19769789460031;
    mockResponse[2] = 115392798491629449445538165;
    mockResponse[3] = 0;
    mockResponse[4] = 36000;
    mockResponse[5] = 85000000000000;
    mockResponse[6] = 120000000000000000000000000;
    mockResponse[7] = 0;
    mockResponse[8] = 0;
    mockResponse[9] = 1000000000000000000000000000000;
    mockResponse[10] = 1000000000000000000000000000000;
    mockResponse[11] = 0;
    mockResponse[12] = 1000043150000000000000000000000;
    mockResponse[13] = 1000043150000000000000000000000;
    mockResponse[14] = 54968982162304021046919;
    mockResponse[15] = 21396301079220989433539;
    mockResponse[16] = 83462112182915936507151092;
    mockResponse[17] = 0;
    mockResponse[18] = 28000;
    mockResponse[19] = 38000000000000000000000;
    mockResponse[20] = 120000000000000000000000000;
    mockResponse[21] = 14516865246876721345766733570143050000;
    mockResponse[22] = 35000000000000000000000000000000000000;
    mockResponse[23] = 1554700000000000000000000000000000;
    mockResponse[24] = 1554700000000000000000000000000000;
    mockResponse[25] = 28782744339874201472004342972754750378;
    mockResponse[26] = 1554100000000000000000000000000000;
    mockResponse[27] = 1554100000000000000000000000000000;

    vm.mockCall(
      mockAddress,
      abi.encodeCall(IVaultReader.getVaultTokenInfoV3, (mockAddress, mockAddress, mockAddress, 1*10**18, tokens)),
      abi.encode(mockResponse)
    );


    vm.mockCall(
      usdcAddress,
      abi.encodeWithSelector(ERC20.symbol.selector),
      abi.encode("USDC")
    );

    vm.mockCall(
      ethAddress,
      abi.encodeWithSelector(ERC20.symbol.selector),
      abi.encode("ETH")
    );

    glpUtils = new GlpUtils();
  }

  function testGetGlpTokenAllocations() public {
    GlpTokenAllocation[] memory glpTokenAllocations = glpUtils.getGlpTokenAllocations(tokens);
    assertEq(glpTokenAllocations.length, 2);

    assertEq(glpTokenAllocations[0].tokenAddress, 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    assertEq(glpTokenAllocations[0].poolAmount, 114197608576723);
    assertEq(glpTokenAllocations[0].usdgAmount, 115392798491629449445538165);
    assertEq(glpTokenAllocations[0].weight, 36000);
    assertEq(glpTokenAllocations[0].allocation, 5802);

    assertEq(glpTokenAllocations[1].tokenAddress, 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    assertEq(glpTokenAllocations[1].poolAmount, 54968982162304021046919);
    assertEq(glpTokenAllocations[1].usdgAmount, 83462112182915936507151092);
    assertEq(glpTokenAllocations[1].weight, 28000);
    assertEq(glpTokenAllocations[1].allocation, 4197);
  }

  function testGetGlpTokenExposure() public {
    TokenExposure[] memory glpTokenExposures = glpUtils.getGlpTokenExposure(1*10**6, tokens);
    assertEq(glpTokenExposures.length, 2);
    
    assertEq(glpTokenExposures[0].token, 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    assertEq(glpTokenExposures[0].amount, 580200);
    assertEq(glpTokenExposures[0].symbol, "USDC");

    assertEq(glpTokenExposures[1].token, 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    assertEq(glpTokenExposures[1].amount, 419700);
    assertEq(glpTokenExposures[1].symbol, "ETH"); 
  }
}