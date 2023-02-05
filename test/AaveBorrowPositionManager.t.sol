// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {GlpUtils} from "src/GlpUtils.sol";
import {IVaultReader} from "gmx/IVaultReader.sol";
import {IGmxRouter} from "gmx/IGmxRouter.sol";
import {GlpTokenAllocation} from "src/GlpTokenAllocation.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {AaveBorrowPositionManager,InitializeArgs} from "src/AaveBorrowPositionManager.sol";
import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {MintableToken} from "test/mocks/MintableToken.sol";
import {IAaveL2Pool} from "aave/IAaveL2Pool.sol";
import {IAaveL2Encoder} from "aave/IAaveL2Encoder.sol";
import {PriceUtils} from "src/PriceUtils.sol";

contract AaveBorrowPositionManagerTest is Test {
    using stdStorage for StdStorage;
    StdStorage internal stdStore;

    AaveBorrowPositionManager private aaveBorrowPositionManager;
    address private mockAddress = address(0);
    address private protohedgeVaultAddress = address(1);
    uint256 targetLtv = 60;

    MintableToken private usdcToken;
    MintableToken private borrowToken;

    function setUp() public {
        usdcToken = new MintableToken("USDC", "USDC", 6);
        borrowToken = new MintableToken("WBTC", "WBTC", 8);
        usdcToken.mint(protohedgeVaultAddress, 1 * 10**6);

        vm.mockCall(
            mockAddress,
            abi.encodeCall(ProtohedgeVault.getAvailableLiquidity, ()),
            abi.encode(1 * 10**6)
        );

        vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(IAaveL2Encoder.encodeSupplyParams.selector),
            abi.encode(0x01)
        );

        vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(IAaveL2Pool.supply.selector),
            abi.encode()
        );

        vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(IAaveL2Encoder.encodeBorrowParams.selector),
            abi.encode(0x02)
        );

        vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(IAaveL2Pool.borrow.selector),
            abi.encode()
        );

        vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(IGmxRouter.swap.selector),
            abi.encode()
        );

        vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(PriceUtils.getTokenPrice.selector),
            abi.encode(16000 * (1 * 10**8))
        );

        vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(IAaveL2Encoder.encodeRepayParams.selector),
            abi.encode(0x03)
        );

        vm.mockCall(
          mockAddress,
          abi.encodeWithSelector(IAaveL2Pool.repay.selector),
          abi.encode(1)
        );

        vm.mockCall(
          protohedgeVaultAddress,
          abi.encodeWithSelector(ProtohedgeVault.getAvailableLiquidity.selector),
          abi.encode(2*10**6)
        );

        aaveBorrowPositionManager = new AaveBorrowPositionManager();

        InitializeArgs memory args = InitializeArgs({
            positionName: "TestPositionManager",
            decimals: 8,
            targetLtv: targetLtv,
            tokenPriceFeedAddress: mockAddress,
            aaveL2PoolAddress: mockAddress,
            aaveL2EncoderAddress: mockAddress,
            usdcAddress: address(usdcToken),
            borrowTokenAddress: address(borrowToken),
            protohedgeVaultAddress: protohedgeVaultAddress,
            priceUtilsAddress: mockAddress,
            gmxRouterAddress: mockAddress,
            glpUtilsAddress: mockAddress,
            aaveProtocolDataProviderAddress: mockAddress
        });

        aaveBorrowPositionManager.initialize(args);

        vm.prank(protohedgeVaultAddress);
        usdcToken.approve(address(aaveBorrowPositionManager), 1 * 10**6);
    }

    function testBuy() public {
        uint256 amountToBuy = 1 * 10**6;

        vm.expectCall(
            address(mockAddress),
            abi.encodeCall(
                IAaveL2Encoder.encodeSupplyParams,
                (address(usdcToken), 1 * 10**6, 0)
            )
        );

        vm.expectCall(
            address(mockAddress),
            abi.encodeCall(
                IAaveL2Encoder.encodeBorrowParams,
                (address(borrowToken), 3750, 2, 0)
            )
        );

        address[] memory swapPath = new address[](2);
        swapPath[0] = address(borrowToken);
        swapPath[1] = address(usdcToken);

        vm.expectCall(
            address(mockAddress),
            abi.encodeCall(
                IGmxRouter.swap,
                (swapPath, 3750, 0, protohedgeVaultAddress)
            )
        );

        aaveBorrowPositionManager.buy(amountToBuy);

        assertEq(aaveBorrowPositionManager.positionWorth(), 1600000);
        assertEq(aaveBorrowPositionManager.costBasis(), 1600000);
    }

    function testSell() public {
        uint256 collateral = 1 * 10**6;

        stdStore
            .target(address(aaveBorrowPositionManager))
            .sig(aaveBorrowPositionManager.collateral.selector)
            .checked_write(collateral);

        stdStore
            .target(address(aaveBorrowPositionManager))
            .sig(aaveBorrowPositionManager.usdcAmountBorrowed.selector)
            .checked_write((collateral * targetLtv) / 100);

        address[] memory swapPath = new address[](2);
        swapPath[0] = address(usdcToken);
        swapPath[1] = address(borrowToken);

        vm.expectCall(
            address(mockAddress),
            abi.encodeCall(
                IGmxRouter.swap,
                (swapPath, 303000, 1875, address(aaveBorrowPositionManager))
            )
        );

        vm.expectCall(
            address(mockAddress),
            abi.encodeCall(
                IAaveL2Encoder.encodeRepayParams,
                (address(borrowToken), 1875, 0)
            )
        );

        aaveBorrowPositionManager.sell(500000);
    }
}
