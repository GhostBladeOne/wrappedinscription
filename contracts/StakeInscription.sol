// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract StakeInscription is Ownable, ReentrancyGuard {
    struct RedeemInfo {
        uint256 amount;
        uint256 endTime;
    }

    bytes32 public tickHash;
    uint256 public RedeemDuration = 3 days;

    uint256 private _totalSupply;

    mapping(address => RedeemInfo[]) public userRedeems;
    mapping(address => uint256) private _balances;

    event MintInscription(address indexed to, bytes32 tickHash, uint256 amount);

    event BurnInscription(bytes32 tickHash, uint256 amount);

    event WithdrawInscription(
        address indexed redeemer,
        // bytes32 txHash,
        uint256 amount
    );

    event Redeem(address indexed userAddress, uint256 amount, uint256 duration);
    event FinalizeRedeem(address indexed userAddress, uint256 amount);
    event CancelRedeem(address indexed userAddress, uint256 amount);

    modifier validateRedeem(address userAddress, uint256 redeemIndex) {
        require(
            redeemIndex < userRedeems[userAddress].length,
            "validateRedeem: redeem entry does not exist"
        );
        _;
    }

    constructor(bytes32 _tickHash) Ownable(msg.sender) {
        tickHash = _tickHash;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function setUserBalance(address _user, uint256 _amount) public onlyOwner {
        require(
            tickHash != bytes32(0),
            "tickHash has not been initialized yet"
        );
        _balances[_user] = _amount;
        _totalSupply += _amount;
    }

    function setMaxRedeemDuration(uint256 _duration) public onlyOwner {
        RedeemDuration = _duration;
    }

    function redeem(uint256 _amount, uint256 duration) external nonReentrant {
        require(
            tickHash != bytes32(0),
            "tickHash has not been initialized yet"
        );
        require(_amount > 0, "redeem: amount cannot be null");
        require(
            _amount <= _balances[msg.sender],
            "redeem: Amount in excess of balance"
        );
        require(duration >= RedeemDuration, "redeem: duration too low");

        _balances[msg.sender] = _balances[msg.sender] - _amount;

        userRedeems[msg.sender].push(
            RedeemInfo(_amount, block.timestamp + duration)
        );

        emit Redeem(msg.sender, _amount, duration);
    }

    function finalizeRedeem(
        uint256 redeemIndex
    ) external nonReentrant validateRedeem(msg.sender, redeemIndex) {
        RedeemInfo storage _redeem = userRedeems[msg.sender][redeemIndex];
        // require(
        //     block.timestamp >= _redeem.endTime,
        //     "finalizeRedeem: vesting duration has not ended yet"
        // );

        _totalSupply -= _redeem.amount;

        _deleteRedeemEntry(redeemIndex);
        emit FinalizeRedeem(msg.sender, _redeem.amount);
        emit BurnInscription(tickHash, _redeem.amount);
        emit WithdrawInscription(msg.sender, _redeem.amount);
    }

    function cancelRedeem(
        uint256 redeemIndex
    ) external nonReentrant validateRedeem(msg.sender, redeemIndex) {
        RedeemInfo storage _redeem = userRedeems[msg.sender][redeemIndex];

        _balances[msg.sender] = _balances[msg.sender] + _redeem.amount;

        emit CancelRedeem(msg.sender, _redeem.amount);
        _deleteRedeemEntry(redeemIndex);
    }

    function getUserRedeem(
        address userAddress,
        uint256 redeemIndex
    )
        external
        view
        validateRedeem(userAddress, redeemIndex)
        returns (uint256 amount, uint256 endTime)
    {
        RedeemInfo storage _redeem = userRedeems[userAddress][redeemIndex];
        return (_redeem.amount, _redeem.endTime);
    }

    function getUserRedeemsLength(
        address userAddress
    ) external view returns (uint256) {
        return userRedeems[userAddress].length;
    }

    function _deleteRedeemEntry(uint256 index) internal {
        userRedeems[msg.sender][index] = userRedeems[msg.sender][
            userRedeems[msg.sender].length - 1
        ];
        userRedeems[msg.sender].pop();
    }
}
