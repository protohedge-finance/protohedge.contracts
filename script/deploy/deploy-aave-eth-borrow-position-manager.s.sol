// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {AaveBorrowPositionManager,InitializeArgs} from "src/AaveBorrowPositionManager.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";

contract DeployAaveEthBorrowPositionManager is Script, Deployer {
  function run() public returns (address) {
    vm.startBroadcast(); 

    AaveBorrowPositionManager implementation = new AaveBorrowPositionManager();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    address proxyAddress = address(proxy);
    AaveBorrowPositionManager wrapped = AaveBorrowPositionManager(proxyAddress);

    InitializeArgs memory args = InitializeArgs({
      positionName: vm.envString("AAVE_BORROW_ETH_POSITION_MANAGER_NAME"),
      decimals: vm.envUint("AAVE_BORROW_ETH_POSITION_MANAGER_DECIMALS"),
      targetLtv: vm.envUint("AAVE_BORROW_ETH_TARGET_LTV"),
      tokenPriceFeedAddress: vm.envAddress("ETH_PRICE_FEED"),
      aaveL2PoolAddress: vm.envAddress("AAVE_L2_POOL"),
      aaveL2EncoderAddress: vm.envAddress("AAVE_L2_ENCODER"),
      usdcAddress: vm.envAddress("USDC"),
      borrowTokenAddress: vm.envAddress("ETH"),
      protohedgeVaultAddress: vm.envAddress("GLP_AAVE_BORROW_VAULT"),
      priceUtilsAddress: vm.envAddress("PRICE_UTILS"),
      gmxRouterAddress: vm.envAddress("GMX_ROUTER"),
      glpUtilsAddress: vm.envAddress("GLP_UTILS"),
      aaveProtocolDataProviderAddress: vm.envAddress("AAVE_PROTOCOL_DATA_PROVIDER")
    });

    wrapped.initialize(args);


    vm.setEnv("AAVE_BORROW_ETH_POSITION_MANAGER", toString(proxyAddress));
    vm.stopBroadcast();
    return proxyAddress;
  } 
}