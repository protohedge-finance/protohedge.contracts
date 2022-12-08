// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {PerpPoolUtils} from "src/PerpPoolUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {GlpPositionManager} from "src/GlpPositionManager.sol";

contract UpdateGlpPositionManager is Script, Test, Deployer {
  
  function run() public returns (address) {
    vm.startBroadcast();

    address glpPositionManagerAddress = vm.envAddress("GLP_POSITION_MANAGER");

    GlpPositionManager glpPositionManager = GlpPositionManager(glpPositionManagerAddress);
    GlpPositionManager implementation = new GlpPositionManager();

    glpPositionManager.upgradeTo(address(implementation));

    emit log_named_string("Updated GlpPositionManager to: ", toString(address(implementation)));

    vm.stopBroadcast();

    return glpPositionManagerAddress;
  }
}