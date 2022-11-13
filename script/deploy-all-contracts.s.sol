// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/stdlib.sol";

import {PriceUtils} from "src/PriceUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DeployHelper} from "src/DeployHelper.sol";
import {DeployPriceUtils} from "script/deploy-price-utils.s.sol";
import {DeployGlpUtils} from "script/deploy-glp-utils.s.sol";
import {DeployPerpPoolUtils} from "script/deploy-perp-pool-utils.s.sol";
import {DeployGlpPerpPoolVault} from "script/deploy-glp-perp-pool-vault.s.sol";
import {DeployBtcPerpPoolPositionManager} from "script/deploy-btc-perp-pool-position-manager.s.sol";
import {DeployEthPerpPoolPositionManager} from "script/deploy-eth-perp-pool-position-manager.s.sol";
import {DeployGlpPositionManager} from "script/deploy-glp-position-manager.s.sol";
import {GlpPositionManager} from "src/GlpPositionManager.sol";
import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract DeployAllContracts is Script, Test {
  using DeployHelper for address;
  using stdStorage for StdStorage;
  StdStorage stdstore;


  function run() public {
    DeployPriceUtils deployPriceUtils = new DeployPriceUtils();    
    DeployGlpUtils deployGlpUtils = new DeployGlpUtils();
    DeployPerpPoolUtils deployPerpPoolUtils = new DeployPerpPoolUtils();
    DeployGlpPerpPoolVault deployGlpPerpPoolVault = new DeployGlpPerpPoolVault();
    DeployBtcPerpPoolPositionManager deployBtcPerpPoolPositionManager = new DeployBtcPerpPoolPositionManager();
    DeployEthPerpPoolPositionManager deployEthPerpPoolPositionManager = new DeployEthPerpPoolPositionManager();
    DeployGlpPositionManager deployGlpPositionManager = new DeployGlpPositionManager();

    address priceUtilsAddress = deployPriceUtils.run();
    address glpUtilsAddress = deployGlpUtils.run();
    address perpPoolUtilsAddress = deployPerpPoolUtils.run(); 
    address glpPerpPoolVaultAddress = deployGlpPerpPoolVault.run();
    address btcPerpPoolPositionManagerAddress = deployBtcPerpPoolPositionManager.run();
    address ethPerpPoolPositionManagerAddress = deployEthPerpPoolPositionManager.run();
    address glpPositionManagerAddress = deployGlpPositionManager.run();

    deployGlpPositionManager.setGlpTokens(glpPositionManagerAddress);

    IPositionManager[] memory glpPerpPoolPositionManagers = new IPositionManager[](3);
    glpPerpPoolPositionManagers[0] = IPositionManager(glpPositionManagerAddress);
    glpPerpPoolPositionManagers[1] = IPositionManager(btcPerpPoolPositionManagerAddress);
    glpPerpPoolPositionManagers[2] = IPositionManager(ethPerpPoolPositionManagerAddress);
    deployGlpPerpPoolVault.setPositionManagers(glpPerpPoolVaultAddress, glpPerpPoolPositionManagers);

    address usdcTokenAddress = vm.envAddress("USDC");
    IERC20 usdcToken = IERC20(usdcTokenAddress);

    uint256 oneDollar = 1*10**6;


    stdstore
      .target(usdcToken)
      .sig(IERC20(usdcToken).balanceOf.selector)
      .with_key(address(glpPerpPoolVaultAddress))
      .checked_write(oneDollar);

    emit log_named_uint256("It is: ", usdcToken.balanceOf(address(glpPerpPoolVaultAddress)));

    vm.stopBroadcast();
     
    emit log_named_address("PriceUtils is: ", priceUtilsAddress);
    emit log_named_address("GlpUtils is: ", glpUtilsAddress);
    emit log_named_address("PerpPoolUtils is: ", perpPoolUtilsAddress);
    emit log_named_address("GlpPerpPoolVault is: ", glpPerpPoolVaultAddress);
    emit log_named_address("BtcPerpPoolPositionManager is: ", btcPerpPoolPositionManagerAddress);
    emit log_named_address("EthPerpPoolPositionManager is: ", ethPerpPoolPositionManagerAddress);
    emit log_named_address("GlpPositionManager is: ", glpPositionManagerAddress);
  } 
}
