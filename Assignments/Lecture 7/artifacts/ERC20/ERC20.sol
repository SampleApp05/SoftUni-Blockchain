// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

interface ERC20 {
    error InsuficientSupply();
    error InsuficientBalance();
    error UnauthorizedAccess();

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
}