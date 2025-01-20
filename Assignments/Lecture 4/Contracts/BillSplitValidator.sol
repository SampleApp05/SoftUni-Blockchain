// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;

error InvalidAmount();
error AmountCantBeSplitEvenly();

contract BillSplitValidator {
    function validateSplit(uint256 amount, uint8 numberOfPeople) public pure returns(uint256 amountPerPerson) {
        uint256 etherAmount = amount * 1 ether;
        
        if (etherAmount == 0) { revert InvalidAmount(); }
        if (etherAmount % numberOfPeople != 0) { revert AmountCantBeSplitEvenly(); }

        return etherAmount / numberOfPeople;
    }
}