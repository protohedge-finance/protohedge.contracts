// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {PerpPoolUtils} from "src/PerpPoolUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DeployHelper} from "src/DeployHelper.sol";

contract DeployGlpPositionManager is Script, Test {
  using DeployHelper for address;
   
  function run() public {
    PerpPoolUtils implementation = new PerpPoolUtils();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    PerpPoolUtils wrapped = PerpPoolUtils(address(proxy));

    emit log_address(address(proxy));

    wrapped.initialize(vm.envAddress("PRICE_UTILS"));
  } 
}