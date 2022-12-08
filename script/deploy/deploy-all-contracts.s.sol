// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {PriceUtils} from "src/PriceUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DeployPriceUtils} from "script/deploy/deploy-price-utils.s.sol";
import {DeployGlpUtils} from "script/deploy/deploy-glp-utils.s.sol";
import {DeployPerpPoolUtils} from "script/deploy/deploy-perp-pool-utils.s.sol";
import {DeployGlpPerpPoolVault} from "script/deploy/deploy-glp-perp-pool-vault.s.sol";
import {DeployBtcPerpPoolPositionManager} from "script/deploy/deploy-btc-perp-pool-position-manager.s.sol";
import {DeployEthPerpPoolPositionManager} from "script/deploy/deploy-eth-perp-pool-position-manager.s.sol";
import {DeployGlpPositionManager} from "script/deploy/deploy-glp-position-manager.s.sol";
import {DeployAaveBtcBorrowPositionManager} from "script/deploy/deploy-aave-btc-borrow-position-manager.s.sol";
import {DeployAaveEthBorrowPositionManager} from "script/deploy/deploy-aave-eth-borrow-position-manager.s.sol";
import {GlpPositionManager} from "src/GlpPositionManager.sol";
import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {AaveBorrowPositionManager} from "src/AaveBorrowPositionManager.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract DeployAllContracts is Script, Test {
  using stdStorage for StdStorage;

  function run() public {
    address priceUtilsAddress = new DeployPriceUtils().run();    
    address glpUtilsAddress = new DeployGlpUtils().run();
    address perpPoolUtilsAddress = new DeployPerpPoolUtils().run();
    DeployGlpPerpPoolVault deployGlpPerpPoolVault = new DeployGlpPerpPoolVault();
    address glpPerpPoolVaultAddress = deployGlpPerpPoolVault.run(); 
    address btcPerpPoolPositionManagerAddress = new DeployBtcPerpPoolPositionManager().run();
    address ethPerpPoolPositionManagerAddress = new DeployEthPerpPoolPositionManager().run();
    address aaveBorrowBtcPositionManagerAddress = new DeployAaveBtcBorrowPositionManager().run();
    address aaveBorrowEthPositionManagerAddress = new DeployAaveEthBorrowPositionManager().run();
    DeployGlpPositionManager deployGlpPositionManager  = new DeployGlpPositionManager();
    address glpPositionManagerAddress = deployGlpPositionManager.run();
   
    deployGlpPositionManager.setGlpTokens(glpPositionManagerAddress);

    IPositionManager[] memory glpPerpPoolPositionManagers = new IPositionManager[](3);
    glpPerpPoolPositionManagers[0] = IPositionManager(glpPositionManagerAddress);
    glpPerpPoolPositionManagers[1] = IPositionManager(aaveBorrowBtcPositionManagerAddress);
    glpPerpPoolPositionManagers[2] = IPositionManager(aaveBorrowEthPositionManagerAddress);

    deployGlpPerpPoolVault.setPositionManagers(glpPerpPoolVaultAddress, glpPerpPoolPositionManagers);

    vm.stopBroadcast();
     
    emit log_named_address("PriceUtils is: ", priceUtilsAddress);
    emit log_named_address("GlpUtils is: ", glpUtilsAddress);
    emit log_named_address("PerpPoolUtils is: ", perpPoolUtilsAddress);

    emit log_named_address("GlpPerpPoolVault is: ", glpPerpPoolVaultAddress);
    
    emit log_named_address("BtcPerpPoolPositionManager is: ", btcPerpPoolPositionManagerAddress);
    emit log_named_address("EthPerpPoolPositionManager is: ", ethPerpPoolPositionManagerAddress);
    emit log_named_address("GlpPositionManager is: ", glpPositionManagerAddress);
    emit log_named_address("AaveBorrowBtcPositionManager is: ", aaveBorrowBtcPositionManagerAddress);
    emit log_named_address("AaveBorrowEthPositionManager is: ", aaveBorrowEthPositionManagerAddress);
  } 
}
