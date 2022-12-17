// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {PerpPoolPositionManager} from "src/PerpPoolPositionManager.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";

contract DeployBtcPerpPoolPositionManager is Script, Test, Deployer {
  
  function run() public returns (address) {
    vm.startBroadcast();

    PerpPoolPositionManager implementation = new PerpPoolPositionManager();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    address proxyAddress = address(proxy);
    PerpPoolPositionManager wrapped = PerpPoolPositionManager(address(proxy));

    wrapped.initialize(
      vm.envString("BTC_PERP_POOL_POSITION_MANAGER_NAME"),
      vm.envAddress("BTC_POOL_TOKEN"),
      vm.envAddress("PRICE_UTILS"),
      vm.envAddress("BTC_LEVERAGED_POOL"),
      vm.envAddress("BTC"),
      vm.envAddress("BTC_POOL_COMMITTER"),
      vm.envAddress("USDC"),
      vm.envAddress("PERP_POOL_UTILS"),
      vm.envAddress("GLP_AAVE_BORROW_VAULT") 
    );

    vm.setEnv("BTC_PERP_POOL_POSITION_MANAGER", toString(proxyAddress));
    vm.stopBroadcast();

    return proxyAddress;
  } 
}