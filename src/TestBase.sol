// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

abstract contract ERC20GasProfileBase is Test {
    string public name;
    string jsonObj;
    address public recipient;
    address public sender;
    uint256 public transferAmount;
    uint256 public mintAmount;
    uint256 public sum;

    function initializeTest(string memory _name) internal {
        name = _name;
        sender = makeAddr("sender");
        recipient = makeAddr("recipient");
        vm.deal(sender, 1 ether);

        erc20Mint();
    }

    function erc20Mint() internal virtual {}

    function erc20Transfer() internal virtual {}

    function erc20BalanceOf(address) internal view virtual returns (uint256) {
        return 0;
    }

    function testTransfer() internal {
        vm.startPrank(sender);
        uint256 gas_before = gasleft();
        uint256 balanceBefore = erc20BalanceOf(recipient);
        erc20Transfer();
        uint256 balanceAfter = erc20BalanceOf(recipient);
        assertEq(balanceAfter, balanceBefore + transferAmount);
        uint256 gas_after = gasleft();
        string memory res = vm.serializeUint(
            jsonObj,
            "transfer",
            gas_before - gas_after
        );
        sum += gas_before - gas_after;
        console.log(res);
        vm.stopPrank();
    }

    function testBenchmark() external {
        testTransfer();
        console.log(jsonObj);
        string memory res = vm.serializeUint(jsonObj, "sum", sum);
        vm.writeJson(
            res,
            string(abi.encodePacked("./results/", name, ".json"))
        );
    }
}
