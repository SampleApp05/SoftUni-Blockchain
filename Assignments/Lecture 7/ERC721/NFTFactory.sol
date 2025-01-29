// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import {MockBaseNFTContract} from "./ERC721.sol";

enum NFTLevel {
    novice,
    experianced,
    addict
}

contract NFTFactory {
    mapping(NFTLevel => MockBaseNFTContract) public nfts;

    constructor() {
        nfts[NFTLevel.novice] = new MockBaseNFTContract("novice", "N");
        nfts[NFTLevel.experianced] = new MockBaseNFTContract("experianced", "E");
        nfts[NFTLevel.addict] = new MockBaseNFTContract("addict", "A");
    }

    function awardNFT(address target, NFTLevel level) public {
        require(target != address(0), "Invalid recepient address");

        nfts[level].mint(target);
    }

    function balanceOf(address target) public view returns(uint256, uint256, uint256) {
        require(target != address(0), "Invalid recepient address");
        
        return (
            nfts[NFTLevel.novice].balanceOf(target),
            nfts[NFTLevel.experianced].balanceOf(target),
            nfts[NFTLevel.addict].balanceOf(target)
        );
    }
}