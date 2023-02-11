// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {GlpPositionManager} from "src/GlpPositionManager.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";

contract DeployGlpPositionManager is Script, Test, Deployer {
  function run() public returns (address) {
    vm.startBroadcast();

    GlpPositionManager implementation = new GlpPositionManager();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    address proxyAddress = address(proxy);
    GlpPositionManager wrapped = GlpPositionManager(proxyAddress);


    wrapped.initialize(
      vm.envAddress("PRICE_UTILS"),
      vm.envAddress("GLP_UTILS"),
      vm.envAddress("GLP_MANAGER"),
      vm.envAddress("USDC"),
      vm.envAddress("ETH"),
      vm.envAddress("ETH_PRICE_FEED"),
      vm.envAddress("REWARD_ROUTER"),
      vm.envAddress("GLP_AAVE_BORROW_VAULT"),
      vm.envAddress("STAKED_GLP")
    );

    vm.setEnv("GLP_POSITION_MANAGER", toString(proxyAddress));
    vm.stopBroadcast();

    return proxyAddress;
  } 

  function setGlpTokens(address glpPositionManagerAddress) external {
    vm.startBroadcast();
    GlpPositionManager glpPositionManager = GlpPositionManager(glpPositionManagerAddress);

    address[] memory glpTokens = new address[](5);
    glpTokens[0] = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    glpTokens[1] = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    glpTokens[2] = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    glpTokens[3] = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    glpTokens[4] = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    glpPositionManager.setGlpTokens(glpTokens);

    vm.stopBroadcast();
  }
}