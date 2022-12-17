// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";
import {IPositionManager} from "src/IPositionManager.sol";

contract UpdateGlpAaveBorrowVault is Script, Test, Deployer {
  
  function run() public returns (address) {
    vm.startBroadcast();

    address perpPoolsVaultAddress = vm.envAddress("GLP_AAVE_BORROW_VAULT");

    ProtohedgeVault perpPoolsVault = ProtohedgeVault(perpPoolsVaultAddress);
    ProtohedgeVault implementation = new ProtohedgeVault();

    perpPoolsVault.upgradeTo(address(implementation));

    emit log_named_string("Glp Perp Pools Vault: ", toString(address(implementation)));

    vm.stopBroadcast();

    return perpPoolsVaultAddress;
  }
}