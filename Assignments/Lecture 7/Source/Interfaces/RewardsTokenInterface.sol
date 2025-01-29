// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

interface RewardsTokenInterface {
    function rewardPoints(address target, uint256 amount) external;
    function redeemPoints(uint256 amount) external payable;
}
