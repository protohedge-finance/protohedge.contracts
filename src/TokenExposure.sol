// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPositionManager} from "src/IPositionManager.sol";

struct TokenExposure {
  int256 amount;
  address token; 
  string symbol;
}

struct NetTokenExposure {
  int256 amount;
  address token; 
  uint32 amountOfPositions;
}

