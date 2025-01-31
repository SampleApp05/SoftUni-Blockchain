// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

library PaymentLibrary {
    error InsuficientAmount();

    function transferETH(address target, uint256 amount) external {
        if (amount < 1000 wei) { revert InsuficientAmount();}
        require(target != address(0), "Invalid target address");

        (bool success, ) = target.call{value: amount}("");

        require(success, "Tranfer failed!");
    }

    function isContract(address target) public view returns(bool) {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(target)
        }

        return codeSize > 0;
    }
}

contract PaymentProcessor is AccessControl {
    error InsuficientBalance();
    error InvalidAllocationPercentage();

    event TranferCompleted(address target, uint256 amount);
    event AllocationCompleted(address target, uint256 amount);
    event TreasuryHandlerAdded(address target);
    event TreasuryAddressUpdated(address target, address handler);
    event AllocationPercentageUpdated(uint8 allocationPercentage, address handler);

    bytes32 private constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    address payable public treasury;
    uint8 public allocationPercentage;

    using PaymentLibrary for address payable;

    modifier onlyTreasuryHandler {
        _checkRole(TREASURY_ROLE, msg.sender);
        _;
    }

    modifier _addressValidator(address target) {
        require(target != address(0), "Invalid target address");
        _;
    }

    modifier _allocationValidator(uint8 allocation) {
        if (allocation >= 100) { revert InvalidAllocationPercentage(); }
        _;
    }

    constructor(address payable _treasury, uint8 _allocationPercentage) _allocationValidator(_allocationPercentage) {
        treasury = _treasury;
        allocationPercentage = _allocationPercentage;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addTreasuryHandler(address target) _addressValidator(target) public {
        grantRole(TREASURY_ROLE, target);
        emit TreasuryHandlerAdded(target);
    }

    function updateTreasury(address payable target) _addressValidator(target) onlyTreasuryHandler public {
        treasury = target;
        emit TreasuryAddressUpdated(target, msg.sender);
    }

    function updateAllocationAmount(uint8 allocation) _allocationValidator(allocation) onlyTreasuryHandler public {
        allocationPercentage = allocation;
        emit AllocationPercentageUpdated(allocation, msg.sender);
    }

    function proccessPayment(address payable target) public payable {
        if (msg.sender.balance < msg.value) { revert InsuficientBalance(); }
        require(msg.value != 0, "Not enough funds sent!");
        
        uint256 totalAmount = msg.value;

        uint256 treasuryAmount = (totalAmount * allocationPercentage) / 100;
        uint256 allocationAmount = totalAmount - treasuryAmount;

        require(treasuryAmount + allocationAmount == totalAmount, "Could not proccess transfer amount");

        target.transferETH(allocationAmount);
        emit TranferCompleted(target, allocationAmount);

        treasury.transferETH(treasuryAmount);
        emit AllocationCompleted(target, treasuryAmount);
    }
}