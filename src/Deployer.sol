// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract Deployer {
	 function toString(
      address addr) public pure returns (
      string memory) {
        return Strings.toHexString(uint160(addr), 20);
    }
}
