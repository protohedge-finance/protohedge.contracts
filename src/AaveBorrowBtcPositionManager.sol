// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IAaveL2Pool} from "aave/IAaveL2Pool.sol";
import {IAaveL2Encoder} from "aave/IAaveL2Encoder.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {ProtohedgeVault} from "src/ProtohedgeVault.sol";
import {PriceUtils} from "src/PriceUtils.sol";

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

uint256 constant USDC_MULTIPLIER = 1*10**6; 

contract AaveBorrowBtcPositionManager is IPositionManager, Initializable, UUPSUpgradeable, OwnableUpgradeable {
  string private positionName;
  uint256 private usdcAmountBorrowed;
  bool private _canRebalance;
  uint256 private decimals;
  address private tokenPriceFeedAddress;
  uint256 private targetLtv;
  uint256 private amountOfTokens;
  uint256 private collateral;

  IAaveL2Pool private l2Pool;
  IAaveL2Encoder private l2Encoder;
  ERC20 private usdcToken;
  ERC20 private borrowToken;
  ProtohedgeVault private protohedgeVault;
  PriceUtils private priceUtils;
  

  function initialize(
    string memory _positionName,
    uint256 _decimals,
    uint256 _targetLtv,
    address _tokenPriceFeedAddress,
    address _aaveL2PoolAddress,
    address _aaveL2EncoderAddress,
    address _usdcAddress,
    address _borrowTokenAddress,
    address _protohedgeVaultAddress,
    address _priceUtilsAddress
  ) public initializer {
    positionName = _positionName;
    decimals = _decimals;
    _canRebalance = true;
    tokenPriceFeedAddress = _tokenPriceFeedAddress;
    targetLtv = _targetLtv;

    l2Pool = IAaveL2Pool(_aaveL2PoolAddress);
    l2Encoder = IAaveL2Encoder(_aaveL2EncoderAddress);
    usdcToken = ERC20(_usdcAddress);
    borrowToken = ERC20(_borrowTokenAddress);
    protohedgeVault = ProtohedgeVault(_protohedgeVaultAddress);
    priceUtils = PriceUtils(_priceUtilsAddress);

    __Ownable_init();
  }

  function _authorizeUpgrade(address) internal override onlyOwner {}

  function name() override public view returns (string memory) {
    return positionName;
  }

  function positionWorth() override public view returns (uint256) {
    return collateral + (amountOfTokens * price() / (1*10**decimals));
  }

  function costBasis() override public view returns (uint256) {
    return collateral + usdcAmountBorrowed;
  }

  function pnl() override external view returns (int256) {
    return int256(positionWorth()) - int256(costBasis());
  }

  function buy(uint256 usdcAmount) override external returns (uint256) {
    usdcToken.transferFrom(address(protohedgeVault), address(this), usdcAmount);
    usdcToken.approve(address(l2Pool), usdcAmount);

    bytes32 supplyArgs = l2Encoder.encodeSupplyParams(
      address(usdcToken),
      usdcAmount,
      0
    );

    l2Pool.supply(supplyArgs);

    collateral += usdcAmount;
    uint256 usdcAmountToBorrow = usdcAmount * targetLtv / 100;
    uint256 tokensToBorrow = usdcAmountToBorrow * (1*10**decimals) / price();

    bytes32 borrowArgs = l2Encoder.encodeBorrowParams(
      address(borrowToken),
      tokensToBorrow,
      2, // variable rate mode,
      0  
    );

    l2Pool.borrow(borrowArgs);

    amountOfTokens += tokensToBorrow;
    usdcAmountToBorrow = usdcAmountToBorrow;
     
    return 0;
  }

  function sell(uint256 usdcAmount) override external returns (uint256) {
    return 0;
  }

  function exposures() override external view returns (TokenExposure[] memory) {
    return new TokenExposure[](0);
  }

  function allocation() override external view returns (TokenAllocation[] memory) {
    return new TokenAllocation[](0);
  }

  function price() override public view returns (uint256) {
    uint256 price = priceUtils.getTokenPrice(tokenPriceFeedAddress) / (1*10**2); // Convert to USDC price 
    return price;
  }

  function claim() external {
    }

  function compound() override external {}

  function canRebalance() override external view returns (bool) {
    return _canRebalance;
  }
}