// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

contract MockBaseNFTContract {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    uint256 private _currentTokenID;
    string public name;
    string public symbol;

    mapping(uint256 => address) public holders;
    mapping(address => uint256) public holderBalances;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address target) public view returns(uint256) {
        return holderBalances[target];
    }

    function mint(address target) public {
        require(target != address(0), "Invalid address"); 

        uint256 tokenId = _currentTokenID;
        _currentTokenID++;

        holders[tokenId] = target;
        holderBalances[target]++;

        emit Transfer(address(0), target, tokenId);
    }

    function burn(uint256 tokenId) public {
        address holder = holders[tokenId];

        require(holder == msg.sender,  "Only the owner can burn the token");

        holderBalances[holder]--;
        delete holders[tokenId];

        emit Transfer(holder, address(0), tokenId);
    }

    function transfer(address target, uint256 tokenId) public {
        address owner = holders[tokenId];
        require(owner == msg.sender, " Only owner can transfer the token");
        require(target != address(0), "Invalid address"); 

        holders[tokenId] = target;
        holderBalances[owner]--;
        holderBalances[target]++;


        emit Transfer(owner, target, tokenId);
    }
}