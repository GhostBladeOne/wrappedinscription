// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract WrappedInscription is Ownable {
    IERC20 public token;
    bytes32 public tickHash;
    uint8 public decimals;

    mapping(address => uint256) private _balances;

    event MintInscription(address indexed to, bytes32 tickHash, uint256 amount);

    event BurnInscription(bytes32 tickHash, uint256 amount);

    event WithdrawInscription(
        address indexed redeemer,
        // bytes32 txHash,
        uint256 amount
    );

    constructor(
        IERC20 _token,
        bytes32 _tickHash,
        uint8 _decimals
    ) Ownable(msg.sender) {
        token = _token;
        tickHash = _tickHash;
        decimals = _decimals;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function approve(address teller, uint256 amount) public onlyOwner {
        _balances[teller] = amount;
    }

    function mint(uint256 amount) public {
        require(
            tickHash != bytes32(0),
            "tickHash has not been initialized yet"
        );
        token.transferFrom(msg.sender, address(this), amount);
        emit MintInscription(msg.sender, tickHash, amount);
    }

    function withdraw(address redeemer, uint256 amount) public {
        require(_balances[msg.sender] >= amount, "Not enough balance");
        token.transfer(redeemer, amount);
        _balances[msg.sender] = _balances[msg.sender] - amount;
        emit BurnInscription(tickHash, amount);
        emit WithdrawInscription(redeemer, amount);
    }
}
