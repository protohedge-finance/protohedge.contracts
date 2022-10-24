// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IGlp {
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}