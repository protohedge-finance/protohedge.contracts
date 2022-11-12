// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {NetTokenExposure} from "src/TokenExposure.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {PriceUtils} from "src/PriceUtils.sol";
import {RebalanceAction} from "src/RebalanceAction.sol";
import {ProtohedgeVault} from "src/ProtohedgeVault.sol";

uint256 constant FACTOR_ONE_MULTIPLIER = 1*10**6;
uint256 constant FACTOR_TWO_MULTIPLIER = 1*10**12;
uint256 constant FACTOR_THREE_MULTIPLIER = 1*10**18;


contract DeltaNeutralRebalancer {
  address private usdcAddress;
  mapping(address => ProtohedgeVault) vaults;

  constructor(address _usdcAddress) {
    usdcAddress = _usdcAddress; 
  }


}
