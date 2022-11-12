// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TokenExposure} from "src/TokenExposure.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";

struct PositionManagerStats {
    address positionManagerAddress;
    uint256 positionWorth;
    uint256 costBasis;
    int256 pnl;
    TokenExposure[] tokenExposures;
    TokenAllocation[] tokenAllocation;
    bool canRebalance;
}