// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {PositionManagerStats} from "src/PositionManagerStats.sol";

struct VaultStats {
  address vaultAddress;
  PositionManagerStats[] positionManagers;
  uint256 vaultWorth;	
  uint256 availableLiquidity;
  uint256 positionsWorth;
  uint costBasis;
  int256 pnl;
}
