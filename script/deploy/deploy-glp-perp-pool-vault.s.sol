// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";
import {IPositionManager} from "src/IPositionManager.sol";

contract DeployGlpPerpPoolVault is Script, Deployer {
  function run() public returns (address, address) {
    vm.startBroadcast();
    ProtohedgeVault implementation = new ProtohedgeVault();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    address proxyAddress = address(proxy);
    ProtohedgeVault wrapped = ProtohedgeVault(address(proxy));

    wrapped.initialize(
      vm.envString("GLP_PERP_POOL_VAULT_NAME"),
      vm.envAddress("USDC")
    );

    vm.setEnv("GLP_PERP_POOL_VAULT", toString(proxyAddress));
    vm.stopBroadcast();

    return (proxyAddress, address(implementation));
  }

  function setPositionManagers(address glpPerpPoolVaultAddress, IPositionManager[] memory glpPerpPoolPositionManagers) external {
    vm.startBroadcast();

    ProtohedgeVault glpPerpPoolsVault = ProtohedgeVault(glpPerpPoolVaultAddress);
    glpPerpPoolsVault.setPositionManagers(glpPerpPoolPositionManagers);

    vm.stopBroadcast();
  } 
}