// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Operatable is Ownable {
    event SetOperator(address indexed oldOperator, address indexed newOperator);

    address public operator;

    constructor() {
        operator = msg.sender;
        emit SetOperator(address(0), operator);
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "not operator");
        _;
    }

    function setOperator(address newOperator) public onlyOwner {
        require(newOperator != address(0), "bad new operator");
        address oldOperator = operator;
        operator = newOperator;
        emit SetOperator(oldOperator, newOperator);
    }
}
