// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

interface Stringify {
    function append(string calldata lhs, string calldata rhs) external pure returns(string memory str);
}

contract StringHelper is Stringify {
    function append(string calldata lhs, string calldata rhs) public pure returns(string memory str) {
        return string(abi.encodePacked(lhs, rhs));
    }
}