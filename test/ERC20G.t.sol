// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/TestBase.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {ERC20G} from "src/tokens/erc20g/ERC20G.sol";

contract StandardERC20Test is ERC20GasProfileBase {
    address proxy;

    function setUp() external {
        proxy = Upgrades.deployTransparentProxy(
            "ERC20G.sol",
            msg.sender,
            abi.encodeCall(ERC20G.initialize, ("ERC20G", "ERC20G", 18, 0))
        );
        mintAmount = 1e18;
        transferAmount = 5e17;

        initializeTest("ERC20G");
    }

    function erc20Mint() internal override {
        ERC20G(proxy).mint(sender, mintAmount);
    }

    function erc20Transfer() internal override {
        ERC20G(proxy).transfer(recipient, transferAmount);
    }

    function erc20BalanceOf(
        address account
    ) internal view override returns (uint256) {
        return ERC20G(proxy).balanceOf(account);
    }
}
