// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {PriceUtils} from "src/PriceUtils.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {IVaultReader} from "gmx/IVaultReader.sol";
import {GlpUtils} from "src/GlpUtils.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";
import {GlpTokenAllocation} from "src/GlpTokenAllocation.sol";
import {DeltaNeutralRebalancer} from "src/DeltaNeutralRebalancer.sol";
import {IRewardRouterV2} from "gmx/IRewardRouterV2.sol";
import {IRewardRouter} from "gmx/IRewardRouter.sol";
import {IGlpManager} from "gmx/IGlpManager.sol";
import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {PositionType} from "src/PositionType.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {BASIS_POINTS_DIVISOR} from "src/Constants.sol";
import {RebalanceAction} from "src/RebalanceAction.sol";
import {IStakedGlp} from "gmx/IStakedGlp.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract GlpPositionManager is
    IPositionManager,
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    uint256 public constant USDC_MULTIPLIER = 1 * 10 ** 6;
    uint256 public constant GLP_MULTIPLIER = 1 * 10 ** 18;
    uint256 public constant DEFAULT_SLIPPAGE = 30;
    uint256 public constant PRICE_PRECISION = 10 ** 30;
    uint256 public constant ETH_PRICE_DIVISOR = 1 * 10 ** 20;
    uint256 public constant MIN_SELL_AMOUNT = 1 * USDC_MULTIPLIER;
    uint256 public _costBasis;
    uint256 public tokenAmount;

    PriceUtils public priceUtils;
    GlpUtils public glpUtils;
    ProtohedgeVault public protohedgeVault;
    ERC20 public usdcToken;
    ERC20 public wethToken;
    IRewardRouterV2 public rewardRouterV2;
    IGlpManager public glpManager;
    IStakedGlp public stakedGlp;
    address public ethPriceFeedAddress;
    address[] public glpTokens;
    IRewardRouter public rewardRouter;

    modifier onlyVaultOrOwnerOrSelf() {
        require(
            msg.sender == address(protohedgeVault) ||
                msg.sender == owner() ||
                msg.sender == address(this) // If sender is coming from IPositionManager
        );
        _;
    }

    function initialize(
        address _priceUtilsAddress,
        address _glpUtilsAddress,
        address _glpManagerAddress,
        address _usdcAddress,
        address _wethAddress,
        address _ethPriceFeedAddress,
        address _rewardRouterV2Address,
        address _protohedgeVaultAddress,
        address _stakedGlpAddress,
        address _rewardRouterAddress
    ) public initializer {
        priceUtils = PriceUtils(_priceUtilsAddress);
        glpUtils = GlpUtils(_glpUtilsAddress);
        usdcToken = ERC20(_usdcAddress);
        wethToken = ERC20(_wethAddress);
        protohedgeVault = ProtohedgeVault(_protohedgeVaultAddress);
        rewardRouterV2 = IRewardRouterV2(_rewardRouterV2Address);
        rewardRouter = IRewardRouter(_rewardRouterAddress);
        glpManager = IGlpManager(_glpManagerAddress);
        stakedGlp = IStakedGlp(_stakedGlpAddress);
        ethPriceFeedAddress = _ethPriceFeedAddress;

        __Ownable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function name() public pure override returns (string memory) {
        return "Glp";
    }

    function getTokenAmount() public view returns (uint256) {
        return stakedGlp.balanceOf(address(this));
    }

    function positionWorth() public view override returns (uint256) {
        uint256 glpPrice = priceUtils.glpPrice();
        return ((getTokenAmount() * glpPrice) / GLP_MULTIPLIER);
    }

    function costBasis() public view override returns (uint256) {
        return _costBasis;
    }

    function buy(
        uint256 usdcAmount
    ) external override onlyVaultOrOwnerOrSelf returns (uint256) {
        usdcToken.transferFrom(
            address(protohedgeVault),
            address(this),
            usdcAmount
        );
        usdcToken.approve(address(glpManager), usdcAmount);

        uint256 glpAmount = rewardRouterV2.mintAndStakeGlp(
            address(usdcToken),
            usdcAmount,
            0,
            0
        );

        _costBasis += usdcAmount;
        return glpAmount;
    }

    function sell(
        uint256 usdcAmount
    ) external override onlyVaultOrOwnerOrSelf returns (uint256) {
        uint256 currentPrice = priceUtils.glpPrice();
        uint256 glpToSell = Math.min(
            usdcAmount * currentPrice * usdcToken.decimals(),
            getTokenAmount()
        );
        uint256 usdcRetrieved = rewardRouterV2.unstakeAndRedeemGlp(
            address(usdcToken),
            glpToSell,
            0,
            address(protohedgeVault)
        );

        _costBasis -= usdcRetrieved;
        return 1;
    }

    function pnl() external view override returns (int256) {
        return int256(positionWorth()) - int256(costBasis());
    }

    function exposures()
        external
        view
        override
        returns (TokenExposure[] memory)
    {
        return glpUtils.getGlpTokenExposure(positionWorth(), glpTokens);
    }

    function allocations()
        external
        view
        override
        returns (TokenAllocation[] memory)
    {
        GlpTokenAllocation[] memory glpAllocations = glpUtils
            .getGlpTokenAllocations(glpTokens);
        TokenAllocation[] memory tokenAllocations = new TokenAllocation[](
            glpAllocations.length
        );

        for (uint i = 0; i < glpAllocations.length; i++) {
            tokenAllocations[i] = TokenAllocation({
                tokenAddress: glpAllocations[i].tokenAddress,
                symbol: ERC20(glpAllocations[i].tokenAddress).symbol(),
                percentage: glpAllocations[i].allocation,
                leverage: 1,
                positionType: PositionType.Long
            });
        }

        return tokenAllocations;
    }

    function canRebalance(
        uint256 usdcAmountToHave
    ) external view override returns (bool, string memory) {
        (RebalanceAction rebalanceAction, uint256 amountToBuyOrSell) = this
            .rebalanceInfo(usdcAmountToHave);

        if (
            rebalanceAction == RebalanceAction.Sell &&
            amountToBuyOrSell < MIN_SELL_AMOUNT
        ) {
            return (
                false,
                string.concat(
                    "Min sell amount is",
                    Strings.toString(MIN_SELL_AMOUNT),
                    "but sell amount is",
                    Strings.toString(amountToBuyOrSell),
                    "for position manager",
                    name()
                )
            );
        }

        return (true, "");
    }

    function price() public view override returns (uint256) {
        return priceUtils.glpPrice();
    }

    function compound()
        external
        override
        onlyVaultOrOwnerOrSelf
        returns (uint256)
    {
        uint256 amountOfWethBefore = wethToken.balanceOf(address(this));
        rewardRouter.handleRewards(
            false,
            false,
            false,
            false,
            false,
            true,
            false
        );
        uint256 amountOfWeth = wethToken.balanceOf(address(this));
        emit Compound(amountOfWeth - amountOfWethBefore);
        wethToken.transfer(address(protohedgeVault), amountOfWeth);

        return amountOfWeth;
    }

    function canCompound() external view override returns (bool) {
        return positionWorth() > 0;
    }

    function collateralRatio() external pure override returns (uint256) {
        return BASIS_POINTS_DIVISOR;
    }

    function liquidate() external override onlyVaultOrOwnerOrSelf {
        uint256 glpToSell = getTokenAmount();
        rewardRouterV2.unstakeAndRedeemGlp(
            address(usdcToken),
            glpToSell,
            0,
            address(protohedgeVault)
        );

        uint256 usdcAmount = (getTokenAmount() * price()) / GLP_MULTIPLIER;

        if (int256(glpToSell - usdcAmount) < 0) {
            _costBasis = 0;
        } else {
            _costBasis = glpToSell - usdcAmount;
        }
    }

    function setProtohedgeVault(
        address _protohedgeVaultAddress
    ) external onlyVaultOrOwnerOrSelf {
        protohedgeVault = ProtohedgeVault(_protohedgeVaultAddress);
    }

    function setGlpTokens(
        address[] memory _glpTokens
    ) external onlyVaultOrOwnerOrSelf {
        glpTokens = _glpTokens;
    }

    function protohedgeVaultAddress() public view override returns (address) {
        return address(protohedgeVault);
    }

    function contractOwner() public view override returns (address) {
        return owner();
    }
}
