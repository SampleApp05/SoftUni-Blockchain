// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import {Ownable} from "../Helpers/Ownable.sol";
import {BaseLoyaltyToken} from "./BaseLoyaltyToken.sol";
import {NFTLevel, NFTFactory} from "../ERC721/NFTFactory.sol";

contract BrewBeanPointsToken is BaseLoyaltyToken {
    NFTFactory public nftDistributor = new NFTFactory();

    constructor(address _owner) Ownable(_owner) payable {
        name = "BrewToken";
        symbol = "BT";
        decimals = 8;
        minReward = 0.005 ether;
    }

    // MARK: - Private

    // mock logic, needs to be improved..here just so for the reward redeption
    function _awardNFT(address target, uint256 amount) private {
        if (amount < minReward) { revert InsuficientBalance(); }
        require(amount <= 1 ether, "Invalid amount");

        if (amount > 0.01 ether && amount <= 0.1 ether) {
            nftDistributor.awardNFT(target, NFTLevel.novice);
        } else if (amount > 0.1 ether && amount <= 0.5 ether) {
            nftDistributor.awardNFT(target, NFTLevel.experianced);
        } else if (amount == 1 ether) {
            nftDistributor.awardNFT(target, NFTLevel.addict);
        }
    }

    // MARK: - Internal
    function _authorizeReward(address target) internal view override {
        if (partners[target] == true) { revert UnauthorizedAccess(); } 
        if (target.balance <= (90 ether)) { revert IneligibleUser(); } // arbitrary checks
    }
    
    // MARK: - Public
    function rewardPoints(address target, uint256 amount) onlyPartner _validateAccount(target) _validateAmount(amount) public virtual {
        _authorizeReward(target);

        totalSupply += amount;
        holders[target] += amount;

        emit Rewarded(address(0), target, amount);
    }

    function redeemPoints(uint256 amount) _validateAccount(msg.sender) _validateAmount(amount) public payable virtual {
        _authorizeReward(msg.sender);

        if(holders[msg.sender] < amount) { revert InsuficientBalance(); }

        holders[msg.sender] -= amount;
        totalSupply -= amount;

        _awardNFT(msg.sender, amount);

        emit Redeemed(msg.sender, amount);
    }

    function balance() public view returns(uint256, uint256, uint256) {
        return nftDistributor.balanceOf(msg.sender);
    }
}