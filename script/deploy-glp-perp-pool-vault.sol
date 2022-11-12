// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DeployHelper} from "src/DeployHelper.sol";

contract DeployGlpPerpPoolVault is Script, Test {
  using DeployHelper for address; 
  
  function run() public {
    ProtohedgeVault implementation = new ProtohedgeVault();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    ProtohedgeVault wrapped = ProtohedgeVault(address(proxy));

    emit log_address(address(proxy));

    wrapped.initialize(
      vm.envString("GLP_PERP_POOL_VAULT_NAME"),
      vm.envAddress("USDC")
    );
  } 
}