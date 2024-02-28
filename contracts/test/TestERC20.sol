// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract TestERC20 is ERC20Permit {
    constructor(
        uint256 amountToMint
    ) ERC20("Koge", "Koge") ERC20Permit("Koge Koge") {
        _mint(msg.sender, amountToMint);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
