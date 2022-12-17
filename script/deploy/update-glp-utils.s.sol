// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";
import {GlpUtils} from "src/GlpUtils.sol";

contract UpdateGlpUtils is Script, Test, Deployer {
  
  function run() public returns (address) {
    vm.startBroadcast();

    address glpUtilsAddress = vm.envAddress("GLP_UTILS_ADDRESS");

    GlpUtils glpUtils = GlpUtils(glpUtilsAddress);
    GlpUtils implementation = new GlpUtils();

    glpUtils.upgradeTo(address(implementation));

    emit log_named_string("Updated GlpUtils to: ", toString(address(implementation)));

    vm.stopBroadcast();

    return glpUtilsAddress;
  }
}
