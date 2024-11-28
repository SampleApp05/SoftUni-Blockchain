// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;

error InsuficientPrincipal();
error InterestDurationTooShort();
error InterestRateTooLow();

contract CompoundInterestCalculator {
    function calculateCompoundInterest(uint256 principal, uint8 rate, uint8 numberOfYears) public pure returns (uint256 amount) {
        if (principal == 0) { revert InsuficientPrincipal(); }
        if (numberOfYears < 1) { revert InterestDurationTooShort(); }
        if (rate < 1) { revert InterestRateTooLow(); }

        uint256 compoundedAmount = principal * 1 ether; // convert to eth to avoid decimal loss

        for (uint8 i = 0; i < numberOfYears; i++) {
            uint256 interest = compoundedAmount * rate / 100;
            compoundedAmount = compoundedAmount + interest;
        }

        return compoundedAmount;
    }

    // Helper for task 2
    function calculateSalaryBonus(uint256 principal) external pure returns (uint256 amount) {
        return calculateCompoundInterest(principal, 10, 1);
    }
}