// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solady/tokens/ERC20.sol";

contract StandardERC20 is ERC20 {
    function name() public pure override returns (string memory) {
        return "StandardERC20";
    }

    function symbol() public pure override returns (string memory) {
        return "SERC20";
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}
