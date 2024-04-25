// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Operatable.sol";

contract WrappedInscription is Operatable {
    IERC20 public token;
    string public tickHash;
    bool public limiter = true;

    bool public forbidden;
    uint256 public maxLimit = 100 * 1e18;

    mapping(address => bool) public mintUser;

    mapping(address => uint256) private _balances;

    event MintInscription(address indexed to, string tickHash, uint256 amount);

    event BurnInscription(string tickHash, uint256 amount);

    event WithdrawInscription(
        address indexed redeemer,
        // bytes32 txHash,
        uint256 amount
    );

    constructor(IERC20 _token, string memory _tickHash) Ownable(msg.sender) {
        token = _token;
        tickHash = _tickHash;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function approve(address teller, uint256 amount) public onlyOperator {
        _balances[teller] = amount;
    }

    function mint(string calldata _tickHash, uint256 amount) public {
        require(
            compareStrings(_tickHash, tickHash),
            "tickHash has not been initialized yet"
        );

        if (limiter) {
            require(!mintUser[msg.sender], "Prohibition of convertibility");
            require(amount <= maxLimit, "maxLimit");
        }
        mintUser[msg.sender] = true;
        token.transferFrom(msg.sender, address(this), amount);
        emit MintInscription(msg.sender, tickHash, amount);
    }

    function withdraw(uint256 amount) public {
        address user = msg.sender;
        require(!forbidden, "forbidden");
        require(_balances[user] >= amount, "Not enough balance");
        if (limiter) {
            require(amount <= maxLimit, "maxLimit");
        }
        token.transfer(user, amount);
        _balances[user] = _balances[user] - amount;
        emit BurnInscription(tickHash, amount);
        emit WithdrawInscription(user, amount);
    }

    function withdrawToken(address _token, uint256 amount) public onlyOwner {
        IERC20(_token).transfer(msg.sender, amount);
    }

    function setMaxLimit(uint256 _amount) public onlyOwner {
        maxLimit = _amount;
    }

    function setLimiter(bool _limiter) public onlyOwner {
        limiter = _limiter;
    }

    function setForbidden(bool _forbidden) public onlyOwner {
        forbidden = _forbidden;
    }

    function setMintUser(
        address[] memory _users,
        bool _status
    ) public onlyOwner {
        for (uint i = 0; i < _users.length; i++) {
            mintUser[_users[i]] = _status;
        }
    }

    function compareStrings(
        string memory a,
        string memory b
    ) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
