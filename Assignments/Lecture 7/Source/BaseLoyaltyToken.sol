// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import {Ownable} from "../Helpers/Ownable.sol";
import {ERC20} from "../ERC20/ERC20.sol";
import {RewardsTokenInterface} from "./Interfaces/RewardsTokenInterface.sol";

abstract contract BaseLoyaltyToken is ERC20, Ownable, RewardsTokenInterface {
    error IneligibleUser();

    event Rewarded(address indexed _from, address indexed _to, uint256 _value);
    event Redeemed(address indexed _owner, uint256 _value);

    string public name;
    string public symbol;
    uint8 immutable public decimals;
    uint256 public totalSupply;
    uint256 immutable public minReward;

    mapping(address => uint256) public holders;
    mapping(address => bool) public partners;

    // MARK: - Modifiers
    modifier _validateAccount(address target) virtual {
        require(target != address(0), "Invalid Target Address");
        _;
    }

    modifier _validateAmount(uint256 amount) virtual {
        require(amount >= minReward, "Transfer Amount needs to be at least equal to the minimum Reward");
        _;
    }

    modifier onlyPartner virtual {
        if (partners[msg.sender] == false) { revert UnauthorizedAccess(); } 
        _;
    }

    // MARK: - Internal
    function _authorizeReward(address target) internal view virtual;

    // MARK: - Public
    function balanceOf(address _owner) _validateAccount(_owner) external view returns (uint256 balance) {
        return holders[_owner];
    }

    function transfer(address _to, uint256 _value) _validateAccount(_to) _validateAmount(_value) external returns (bool success) {
        holders[msg.sender] -= _value;
        holders[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function addPartner(address target) onlyOwner _validateAccount(target) public virtual {
        partners[target] = true;
    }

    function removePartner(address target) onlyOwner _validateAccount(target) public virtual {
        partners[target] = false;
    }
}