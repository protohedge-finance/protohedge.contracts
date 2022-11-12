// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {PerpPoolPositionManager} from "src/PerpPoolPositionManager.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DeployHelper} from "src/DeployHelper.sol";

contract DeployEthPerpPoolPositionManager is Script, Test {
  using DeployHelper for address;

  function run() public {
    PerpPoolPositionManager implementation = new PerpPoolPositionManager();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    PerpPoolPositionManager wrapped = PerpPoolPositionManager(address(proxy));

    emit log_address(address(proxy));

    wrapped.initialize(
      vm.envString("name"),
      vm.envAddress("ETH_POOL_TOKEN"),
      vm.envAddress("PRICE_UTILS"),
      vm.envAddress("ETH_LEVERAGED_POOL"),
      vm.envAddress("ETH"),
      vm.envAddress("ETH_POOL_COMMITTER"),
      vm.envAddress("USDC"),
      vm.envAddress("PERP_POOL_UTILS"),
      vm.envAddress("GLP_PERP_POOL_VAULT") 
    );
  } 
}