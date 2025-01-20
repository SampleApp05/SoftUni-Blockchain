// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;

import "./CompoundInterestCalculator.sol";

error InvalidSalaryAmount();
error InvalidRating();

contract PaycheckCalculator {
    CompoundInterestCalculator private _calculator = new CompoundInterestCalculator(); 

    function calculatePaycheck(uint256 salary, uint8 rating) public view returns(uint256 salaryAmount) {
        if (salary == 0) { revert InvalidSalaryAmount(); }
        if (rating > 10) { revert InvalidRating(); }

        if (rating < 8) { return salary * 1 ether; } // transforming to eth for consistency

        uint256 newAmount = _calculator.calculateSalaryBonus(salary);
        return newAmount;
    }
}