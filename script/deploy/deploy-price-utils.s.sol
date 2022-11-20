// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {PriceUtils} from "src/PriceUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";

contract DeployPriceUtils is Script, Test, Deployer {

  function run() public returns (address) {
    vm.startBroadcast();

    PriceUtils implementation = new PriceUtils();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    address proxyAddress = address(proxy);
    PriceUtils wrapped = PriceUtils(proxyAddress);

    wrapped.initialize(
      vm.envAddress("GLP_MANAGER"),
      vm.envAddress("GLP_TOKEN"),
      vm.envAddress("VAULT"),
      vm.envAddress("POOL_STATE_HELPER") 
    );

    vm.stopBroadcast();
    vm.setEnv("PRICE_UTILS", toString(proxyAddress));

    return proxyAddress;
  } 
}