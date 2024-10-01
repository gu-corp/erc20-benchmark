// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

abstract contract ERC20GasProfileBase is Test {
    string public name;
    string jsonObj;
    address public recipient;
    address public sender;
    uint256 public transferAmount;
    uint256 public mintAmount;

    function initializeTest(string memory _name) internal {
        name = _name;
        sender = makeAddr("sender");
        recipient = makeAddr("recipient");
        mintAmount = 1e18;
        transferAmount = 5e17;

        // MockERC20 mockERC20 = new MockERC20();
        // mockERC20.mint(sender, mintAmount);
    }

    function testTransfer() internal {
        // uint256 balance = mockERC20.balanceOf(recipient);
        // string memory res = vm.serializeUint(jsonObj, "sum", sum);
        //         UserOperation memory op = fillUserOp(
        //     fillData(address(mockERC20), 0, abi.encodeWithSelector(mockERC20.transfer.selector, recipient, amount))
        // );
        // executeUserOp(op, "erc20", 0);
        // assertEq(mockERC20.balanceOf(recipient), balance + amount);
    }

    function testTransferFrom() internal {
        // string memory res = vm.serializeUint(jsonObj, "sum", sum);
    }

    function testBenchmark() external {
        testTransfer();
        testTransferFrom();
        vm.writeJson(jsonObj, string.concat("./results/", name, ".json"));
    }
}
