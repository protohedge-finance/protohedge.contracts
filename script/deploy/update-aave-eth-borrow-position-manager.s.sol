// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {PerpPoolUtils} from "src/PerpPoolUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {AaveBorrowPositionManager} from "src/AaveBorrowPositionManager.sol";

contract UpdateAaveEthBorrowPositionManager is Script, Test, Deployer {
  
  function run() public returns (address) {
    vm.startBroadcast();

    address aaveEthBorrowPositionManagerAddress = vm.envAddress("AAVE_ETH_BORROW_POSITION_MANAGER");

    AaveBorrowPositionManager aaveEthBorrowPositionManager = AaveBorrowPositionManager(aaveEthBorrowPositionManagerAddress);
    AaveBorrowPositionManager implementation = new AaveBorrowPositionManager();

    aaveEthBorrowPositionManager.upgradeTo(address(implementation));

    emit log_named_string("Updated AaveEthBorrowPositionManager to: ", toString(address(implementation)));

    vm.stopBroadcast();

    return aaveEthBorrowPositionManagerAddress;
  }
}
