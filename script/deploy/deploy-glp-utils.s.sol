// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {GlpUtils} from "src/GlpUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";

contract DeployGlpUtils is Script, Test, Deployer {
  function run() public returns (address) {
    vm.startBroadcast(); 

    GlpUtils implementation = new GlpUtils();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    address proxyAddress = address(proxy);
    GlpUtils wrapped = GlpUtils(proxyAddress);

    wrapped.initialize(
      vm.envAddress("VAULT_READER"),
      vm.envAddress("VAULT"),
      vm.envAddress("POSITION_MANAGER"),
      vm.envAddress("ETH") 
    );

    vm.setEnv("GLP_UTILS", toString(proxyAddress));
    vm.stopBroadcast();
    return proxyAddress;
  } 
}