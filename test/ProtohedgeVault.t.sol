// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {RebalanceQueueData} from "src/ProtohedgeVault.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

uint256 constant rebalancePercent = 2000;

contract ProtohedgeVaultTest is Test {
    ProtohedgeVault private protohedgeVault;
    address private mockAddress;
    address private positionManagerLongAddress = address(1);
    address private positionManagerShortAddress = address(2);
    address private btcAddress = address(3);

    function setUp() public { 
        mockAddress = address(0);
       
        TokenExposure[] memory tokenExposures = new TokenExposure[](1);
        tokenExposures[0] = TokenExposure({
          amount: 1*10**6,
          token: btcAddress,
          symbol: "BTC"
        });

        vm.mockCall(
          positionManagerLongAddress,
          abi.encodeWithSelector(IPositionManager.exposures.selector),
          abi.encode(tokenExposures)
        );

        TokenExposure[] memory tokenCompareExposures = new TokenExposure[](1);
        tokenCompareExposures[0] = TokenExposure({
          amount: 1*10**6,
          token: btcAddress,
          symbol: "BTC"
        });

        vm.mockCall(
          positionManagerShortAddress,
          abi.encodeWithSelector(IPositionManager.exposures.selector),
          abi.encode(tokenCompareExposures)
        );

        vm.mockCall(
          positionManagerShortAddress,
          abi.encodeWithSelector(IPositionManager.canRebalance.selector),
          abi.encode(false)
        );

        vm.mockCall(
          mockAddress,
          abi.encodeWithSelector(ERC20.approve.selector),
          abi.encode(true)
        );

        protohedgeVault = new ProtohedgeVault();

        protohedgeVault.initialize(
          "ProtohedgeVaultTest",
           mockAddress,
           mockAddress,
           mockAddress,
           rebalancePercent   
        );

        IPositionManager longPositionManager = IPositionManager(positionManagerLongAddress);
        IPositionManager shortPositionManager = IPositionManager(positionManagerShortAddress);

        IPositionManager[] memory positionManagers = new IPositionManager[](2);
        positionManagers[0] = longPositionManager;
        positionManagers[1] = shortPositionManager;
        protohedgeVault.setPositionManagers(positionManagers);
    }
    
    function testShouldRebalanceReturnsTrue() public {
        vm.mockCall(
          positionManagerLongAddress,
          abi.encodeWithSelector(IPositionManager.canRebalance.selector),
          abi.encode(true)
        );

        vm.mockCall(
          positionManagerShortAddress,
          abi.encodeWithSelector(IPositionManager.canRebalance.selector),
          abi.encode(true)
        );

         
        RebalanceQueueData[] memory rebalanceQueueData = createTestRebalanceQueueData();
        (bool shouldRebalance,) = protohedgeVault.shouldRebalance(rebalanceQueueData);
        assertFalse(shouldRebalance); 
    }

    function testShouldRebalanceReturnsFalseIfPositionManagerCannotRebalance() public {
        vm.mockCall(
          positionManagerLongAddress,
          abi.encodeWithSelector(IPositionManager.canRebalance.selector),
          abi.encode(false)
        );
            
        RebalanceQueueData[] memory rebalanceQueueData = createTestRebalanceQueueData();
        (bool shouldRebalance,) = protohedgeVault.shouldRebalance(rebalanceQueueData);
        assertFalse(shouldRebalance); 
    } 

    function testShouldRebalanceReturnsFalseIfExposureOutOfRange() public {
        vm.mockCall(
          positionManagerLongAddress,
          abi.encodeWithSelector(IPositionManager.canRebalance.selector),
          abi.encode(true)
        );

        vm.mockCall(
          positionManagerShortAddress,
          abi.encodeWithSelector(IPositionManager.canRebalance.selector),
          abi.encode(true)
        );

        TokenExposure[] memory tokenExposures = new TokenExposure[](1);
        tokenExposures[0] = TokenExposure({
          amount: 2*10**6,
          token: btcAddress,
          symbol: "BTC"
        });

        vm.mockCall(
          positionManagerLongAddress,
          abi.encodeWithSelector(IPositionManager.exposures.selector),
          abi.encode(tokenExposures)
        );

        RebalanceQueueData[] memory rebalanceQueueData = createTestRebalanceQueueData();
        (bool shouldRebalance,) = protohedgeVault.shouldRebalance(rebalanceQueueData);
        assertFalse(shouldRebalance); 
    }

    function createTestRebalanceQueueData() internal view returns (RebalanceQueueData[] memory) {
        RebalanceQueueData[] memory rebalanceQueueData = new RebalanceQueueData[](2);
        rebalanceQueueData[0] = RebalanceQueueData({
            positionManager: IPositionManager(positionManagerLongAddress),
            usdcAmountToHave: 1*10**6
        });

        rebalanceQueueData[1] = RebalanceQueueData({
            positionManager: IPositionManager(positionManagerShortAddress),
            usdcAmountToHave: 1*10**6
        });

        return rebalanceQueueData;
    }
}

