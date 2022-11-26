// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {AaveBorrowBtcPositionManager} from "src/AaveBorrowBtcPositionManager.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";

contract DeployAaveBorrowBtcPositionManager is Script, Deployer {
  function run() public returns (address) {
    vm.startBroadcast(); 

    AaveBorrowBtcPositionManager implementation = new AaveBorrowBtcPositionManager();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    address proxyAddress = address(proxy);
    AaveBorrowBtcPositionManager wrapped = AaveBorrowBtcPositionManager(proxyAddress);

    wrapped.initialize(
      vm.envString("AAVE_BORROW_BTC_POSITION_MANAGER_NAME"),
      vm.envUint("AAVE_BORROW_BTC_POSITION_MANAGER_DECIMALS"),
      vm.envAddress("BTC_PRICE_FEED"),
      vm.envAddress("AAVE_L2_POOL"),
      vm.envAddress("AAVE_L2_ENCODER"),
      vm.envAddress("USDC"),
      vm.envAddress("BTC"),
      vm.envAddress("GLP_PERP_POOL_VAULT"),
      vm.envAddress("PRICE_UTILS")
    );

    vm.setEnv("AAVE_BORROW_BTC_POSITION_MANAGER", toString(proxyAddress));
    vm.stopBroadcast();
    return proxyAddress;
  } 
}