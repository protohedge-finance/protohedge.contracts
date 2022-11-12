// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {GlpUtils} from "src/GlpUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DeployHelper} from "src/DeployHelper.sol";

contract DeployGlpUtils is Script, Test {
  using DeployHelper for address;

  function run() public {
    GlpUtils implementation = new GlpUtils();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    GlpUtils wrapped = GlpUtils(address(proxy));

    emit log_address(address(proxy));

    wrapped.initialize(
      vm.envAddress("VAULT_READER"),
      vm.envAddress("VAULT"),
      vm.envAddress("POSITION_MANAGER"),
      vm.envAddress("ETH") 
    );
  } 
}