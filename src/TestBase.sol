// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "solady/tokens/ERC20.sol";

abstract contract ERC20GasProfileBase is Test {
    string public name;
    string jsonObj;
    address public recipient;
    address public sender;
    uint256 public transferAmount;
    uint256 public mintAmount;
    address public token;
    uint256 public sum;

    function initializeTest(string memory _name) internal {
        name = _name;
        sender = makeAddr("sender");
        recipient = makeAddr("recipient");
        mintAmount = 1e18;
        transferAmount = 5e17;
        vm.deal(sender, 1 ether);
        vm.startPrank(sender);
    }

    function testTransfer() internal {
        uint256 balance = ERC20(token).balanceOf(recipient);
        uint256 gas_before = gasleft();
        ERC20(token).transfer(recipient, transferAmount);
        uint256 gas_after = gasleft();
        assertEq(ERC20(token).balanceOf(recipient), balance + transferAmount);
        string memory res = vm.serializeUint(
            jsonObj,
            "transfer",
            gas_before - gas_after
        );
        sum += gas_before - gas_after;
        console.log(res);
    }

    function testTransferFrom() internal {
        uint256 balance = ERC20(token).balanceOf(recipient);
        ERC20(token).approve(sender, UINT256_MAX);
        uint256 gas_before = gasleft();
        ERC20(token).transferFrom(sender, recipient, transferAmount);
        uint256 gas_after = gasleft();
        assertEq(ERC20(token).balanceOf(recipient), balance + transferAmount);
        string memory res = vm.serializeUint(
            jsonObj,
            "transferFrom",
            gas_before - gas_after
        );
        sum += gas_before - gas_after;
        console.log(res);
    }

    function testBenchmark() external {
        testTransfer();
        testTransferFrom();
        string memory res = vm.serializeUint(jsonObj, "sum", sum);
        vm.writeJson(res, string.concat("./results/", name, ".json"));
    }
}
