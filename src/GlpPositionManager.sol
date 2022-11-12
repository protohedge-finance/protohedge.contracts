// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {PriceUtils} from "src/PriceUtils.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {IVaultReader} from "gmx/IVaultReader.sol";
import {IGlpUtils} from "src/IGlpUtils.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";
import {GlpTokenAllocation} from "src/GlpTokenAllocation.sol";
import {DeltaNeutralRebalancer} from "src/DeltaNeutralRebalancer.sol";
import {IRewardRouter} from "gmx/IRewardRouter.sol";
import {IGlpManager} from "gmx/IGlpManager.sol";
import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {PositionType} from "src/PositionType.sol";

// Open Zeppelin libraries for controlling upgradability and access.
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/OwnableUpgradeable.sol";

contract GlpPositionManager is IPositionManager, Ownable, Test {
  uint256 private constant USDC_MULTIPLIER = 1*10**6;
  uint256 private constant GLP_MULTIPLIER = 1*10**18;
  uint256 private constant PERCENT_DIVISOR = 1000;
  uint256 private constant BASIS_POINTS_DIVISOR = 10000;
  uint256 private constant DEFAULT_SLIPPAGE = 30;
  uint256 private constant PRICE_PRECISION = 10 ** 30;
  uint256 private constant ETH_PRICE_DIVISOR = 1*10**20;

  uint256 private _costBasis;
  uint256 private tokenAmount;

  PriceUtils private priceUtils;
  IGlpUtils private glpUtils;
  ProtohedgeVault private protohedgeVault;
  ERC20 private usdcToken;
  ERC20 private wethToken;
  IRewardRouter private rewardRouter;
  IGlpManager private glpManager;
  address private ethPriceFeedAddress;
  address[] private glpTokens;

  modifier onlyVault {
    require(msg.sender == address(protohedgeVault));
    _;
  }

  constructor(
    address _priceUtilsAddress,
    address _glpUtilsAddress,
    address _glpManagerAddress,
    address _usdcAddress,
    address _wethAddress,
    address _ethPriceFeedAddress, 
    address _rewardRouterAddress,
    address _protohedgeVaultAddress 
  ) {
    priceUtils = PriceUtils(_priceUtilsAddress);
    glpUtils = IGlpUtils(_glpUtilsAddress);
    usdcToken = ERC20(_usdcAddress);
    wethToken = ERC20(_wethAddress);
    protohedgeVault = ProtohedgeVault(_protohedgeVaultAddress);
    rewardRouter = IRewardRouter(_rewardRouterAddress);
    glpManager = IGlpManager(_glpManagerAddress);
    ethPriceFeedAddress = _ethPriceFeedAddress;
  }

  function name() override external pure returns (string memory) {
    return "Glp";
  }

  function positionWorth() override public view returns (uint256) {
    uint256 glpPrice = priceUtils.glpPrice();
    return (tokenAmount * glpPrice / GLP_MULTIPLIER);
  }

  function costBasis() override public view returns (uint256) {
    return _costBasis;
  }

  function buy(uint256 usdcAmount) override external returns (uint256) {
    uint256 currentPrice = priceUtils.glpPrice();
    uint256 glpToPurchase = usdcAmount * currentPrice / USDC_MULTIPLIER;
    usdcToken.transferFrom(address(protohedgeVault), address(this), usdcAmount);

    uint256 glpAmountAfterSlippage = glpToPurchase * (BASIS_POINTS_DIVISOR - DEFAULT_SLIPPAGE) / BASIS_POINTS_DIVISOR;
    usdcToken.approve(address(glpManager), usdcAmount);

    uint256 glpAmount = rewardRouter.mintAndStakeGlp(address(usdcToken), usdcAmount, 0, glpAmountAfterSlippage);

    _costBasis += usdcAmount;
    tokenAmount += glpAmount;  
    return glpAmount;
  }

  function sell(uint256 usdcAmount) override external returns (uint256) {
    uint256 currentPrice = priceUtils.glpPrice();
    uint256 glpToSell = usdcAmount * currentPrice / USDC_MULTIPLIER;
    uint256 usdcAmountAfterSlippage = usdcAmount * (BASIS_POINTS_DIVISOR - DEFAULT_SLIPPAGE) / BASIS_POINTS_DIVISOR;

    uint256 usdcRetrieved = rewardRouter.unstakeAndRedeemGlp(address(usdcToken), glpToSell, usdcAmountAfterSlippage, address(protohedgeVault));
    _costBasis -= usdcRetrieved;
    tokenAmount -= glpToSell;
    return usdcRetrieved;
  }

  function pnl() override external view returns (int256) {
    return int256(positionWorth()) - int256(costBasis());
  }

  function exposures() override external view returns (TokenExposure[] memory) {
    return glpUtils.getGlpTokenExposure(positionWorth(), glpTokens);
  }

  function allocation() override external view returns (TokenAllocation[] memory) {
    GlpTokenAllocation[] memory glpAllocations = glpUtils.getGlpTokenAllocations(glpTokens);
    TokenAllocation[] memory tokenAllocations = new TokenAllocation[](glpAllocations.length);

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

  function canRebalance() override external pure returns (bool) {
    return true;
  }

  function price() override external view returns (uint256) {
    return priceUtils.glpPrice();
  }

  function setGlpTokens(address[] memory _glpTokens) external onlyOwner() {
    glpTokens = _glpTokens;
  }

  function compound() override external {
    rewardRouter.handleRewards(false, false, false, false, false, true, false);  
    uint256 amountOfWeth = wethToken.balanceOf(address(this));
    wethToken.approve(address(glpManager), amountOfWeth);
    uint256 usdcAmount = priceUtils.getTokenPrice(ethPriceFeedAddress) * amountOfWeth / ETH_PRICE_DIVISOR;
    uint256 glpAmount = rewardRouter.mintAndStakeGlp(address(wethToken), amountOfWeth, 0, 0);

    _costBasis += uint256(usdcAmount);
    tokenAmount += glpAmount;  
  }
}
