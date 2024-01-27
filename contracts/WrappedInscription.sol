// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract WrappedInscription {
    address public owner;
    IERC20 public token;
    bytes32 public tickHash;
    
    // teller allowances
    mapping(address => uint256) private _allowances;

    event MintInscription(address indexed to, bytes32 tickHash, uint256 amount);
    
    event BurnInscription(bytes32 tickHash, uint256 amount);
    
    event WithdrawInscription(address indexed redeemer, bytes32 txHash, uint256 amount);

    constructor(IERC20 _token) {
        token = _token;
        owner = msg.sender;
    }

    function init(bytes32 _tickHash)public {
        require(msg.sender == owner, "Only owner can init");
        require(tickHash == bytes32(0), "tickHash has already been initialized");
        tickHash = _tickHash;
    }

    function approve(address teller, uint256 amount) public {
        require(msg.sender == owner, "Only owner can approve");
        require(tickHash != bytes32(0), "tickHash has not been initialized yet");
        _allowances[teller] = amount;
    }

    function mint(uint256 amount) public {
        require(tickHash != bytes32(0), "tickHash has not been initialized yet");
        token.transferFrom(msg.sender, address(this), amount);
        emit MintInscription(msg.sender, tickHash, amount);
    }

    function withdraw(address redeemer, bytes32 txHash, uint256 amount) public {
        require(tickHash != bytes32(0), "tickHash has not been initialized yet");
        require(_allowances[msg.sender] >= amount, "Not enough allowance");
        token.transfer(redeemer, amount);
        emit BurnInscription(tickHash, amount);
        emit WithdrawInscription(redeemer, txHash, amount);
    }
}
