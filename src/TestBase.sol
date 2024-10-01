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

    function erc20Transfer() internal virtual {}

    function testTransfer() internal {
        uint256 gas_before = gasleft();
        erc20Transfer();
        uint256 gas_after = gasleft();
        string memory res = vm.serializeUint(
            jsonObj,
            "transfer",
            gas_before - gas_after
        );
        sum += gas_before - gas_after;
        console.log(res);
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
