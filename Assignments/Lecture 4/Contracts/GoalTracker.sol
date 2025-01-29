// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

error InvalidGoalAmount();
error GoalAmountNotSet();
error InvalidSpendingAmount();
error InsuficientTotalSpending();
error BonusAlreadyClaimed();

contract GoalTracker {
    uint256 private bonusAmount = 10;

    mapping(address => uint256) private userGoals;
    mapping(address => uint256) private userTotalSpending;
    mapping(address => bool) private userBonusClaimedTracker;

    function setGoalAmount(uint256 goalAmount) public {
        if (goalAmount == 0) { revert InvalidGoalAmount(); }

        userGoals[msg.sender] = goalAmount;
    }

    function addSpending(uint256 value) public {
        if (value == 0) { revert InvalidSpendingAmount(); }

        userTotalSpending[msg.sender] += value;
    }

    function claimBonus() public returns(uint256 bonusClaimed) {
        address user = msg.sender;

        if (userBonusClaimedTracker[user] == true) { revert BonusAlreadyClaimed(); }

        uint256 goalAmount = userGoals[user];
        if (goalAmount < 1) { revert GoalAmountNotSet(); }

        uint256 totalSpending = userTotalSpending[user];
        if (totalSpending < goalAmount) { revert InsuficientTotalSpending(); }

        uint256 totalBonus;
        
        for (uint32 i = 0; i < totalSpending / goalAmount; i++) {
            totalBonus = totalBonus + bonusAmount;
        }

        userBonusClaimedTracker[user] = true;
        return totalBonus;
    }
}