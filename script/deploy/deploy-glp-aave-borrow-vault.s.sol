// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deployer} from "src/Deployer.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract DeployGlpAaveBorrowVault is Script, Deployer {
    function run() public returns (address) {
        vm.startBroadcast();
        ProtohedgeVault implementation = new ProtohedgeVault();
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
        address proxyAddress = address(proxy);
        ProtohedgeVault wrapped = ProtohedgeVault(address(proxy));

        wrapped.initialize(
            vm.envString("GLP_AAVE_BORROW_VAULT_NAME"),
            vm.envAddress("USDC"),
            vm.envAddress("PRICE_UTILS"),
            vm.envAddress("ETH_PRICE_FEED"),
            vm.envUint("GLP_AAVE_REBALANCE_PERCENT"),
            vm.envAddress("ETH")
        );

        vm.setEnv("GLP_AAVE_BORROW_VAULT", toString(proxyAddress));
        vm.stopBroadcast();

        return (proxyAddress);
    }

    function setPositionManagers(
        address glpAaveBorrowVaultAddress,
        IPositionManager[] memory glpAaveBorrowPositionManagers
    ) external {
        vm.startBroadcast();

        ProtohedgeVault glpAaveBorrowVault = ProtohedgeVault(
            glpAaveBorrowVaultAddress
        );
        glpAaveBorrowVault.setPositionManagers(glpAaveBorrowPositionManagers);

        vm.stopBroadcast();
    }

    function transferToVault(address glpAaveBorrowVaultAddress) external {
        vm.startBroadcast();

        ERC20(vm.envAddress("USDC")).transfer(
            glpAaveBorrowVaultAddress,
            20 * (1 * 10 ** 6)
        );

        vm.stopBroadcast();
    }

    function transferOwnership(
        address glpAaveBorrowVaultAddress,
        address newOwner
    ) external {
        vm.startBroadcast();

        ProtohedgeVault glpAaveBorrowVault = ProtohedgeVault(
            glpAaveBorrowVaultAddress
        );

        glpAaveBorrowVault.transferOwnership(newOwner);

        vm.stopBroadcast();
    }
}
