// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {PriceUtils} from "src/PriceUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DeployHelper} from "src/DeployHelper.sol";

contract DeployPriceUtils is Script, Test {
  using DeployHelper for address;

  function run() public {
    PriceUtils implementation = new PriceUtils();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    PriceUtils wrapped = PriceUtils(address(proxy));

    emit log_address(address(proxy));

    wrapped.initialize(
      vm.envAddress("GLP_MANAGER"),
      vm.envAddress("GLP_TOKEN"),
      vm.envAddress("VAULT"),
      vm.envAddress("POOL_STATE_HELPER") 
    );
  } 
}