// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {PerpPoolUtils} from "src/PerpPoolUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";

contract DeployPerpPoolUtils is Script, Test, Deployer {
  function run() public returns (address) {
    vm.startBroadcast(); 

    PerpPoolUtils implementation = new PerpPoolUtils();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    address proxyAddress = address(proxy);
    PerpPoolUtils wrapped = PerpPoolUtils(proxyAddress);

    wrapped.initialize(vm.envAddress("PRICE_UTILS"));

    vm.stopBroadcast();
    vm.setEnv("PERP_POOL_UTILS", toString(proxyAddress));
    return proxyAddress;
  } 
}