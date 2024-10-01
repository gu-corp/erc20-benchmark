// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/TestBase.sol";
import "src/tokens/StandardERC20.sol";

contract StandardERC20Test is ERC20GasProfileBase {
    function setUp() external {
        StandardERC20 standardERC20 = new StandardERC20();
        token = address(standardERC20);

        initializeTest("StandardERC20");
        standardERC20.mint(sender, mintAmount);
    }
}
