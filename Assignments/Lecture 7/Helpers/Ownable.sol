// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

contract Ownable {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner is permitted this action");
        _;
    }

    // MARK: - Public
    function tranferOwnership(address target) onlyOwner public {
        require(target != address(0) && target != owner, "Invalid Address, if you want to remove the owner use the 'renounceOwnership' function instead");
        owner = target;
    }

    function renounceOwnership() onlyOwner public {
        owner = address(0);
    }
}
