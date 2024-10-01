// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/TestBase.sol";
import "src/tokens/StandardERC20.sol";

contract StandardERC20Test is ERC20GasProfileBase {
    StandardERC20 standardERC20;

    function setUp() external {
        standardERC20 = new StandardERC20();
        mintAmount = 1e18;
        transferAmount = 5e17;

        initializeTest("StandardERC20");
    }

    function erc20Mint() internal override {
        standardERC20.mint(sender, mintAmount);
    }

    function erc20Transfer() internal override {
        standardERC20.transfer(recipient, transferAmount);
    }

    function erc20BalanceOf(
        address account
    ) internal view override returns (uint256) {
        return standardERC20.balanceOf(account);
    }
}
