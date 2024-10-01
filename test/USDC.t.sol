// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity >=0.6.2 <0.9.0;

import "src/TestBase.sol";

import {FiatTokenProxy} from "src/tokens/usdc/FiatTokenProxy/centre-tokens/contracts/v1/FiatTokenProxy.sol";
import {FiatTokenV1} from "src/tokens/usdc/FiatToken/centre-tokens/contracts/v1/FiatTokenV1.sol";
import {FiatTokenV2} from "src/tokens/usdc/FiatToken/centre-tokens/contracts/v2/FiatTokenV2.sol";
import {FiatTokenV2_1} from "src/tokens/usdc/FiatToken/centre-tokens/contracts/v2/FiatTokenV2_1.sol";
import {FiatTokenV2_2} from "src/tokens/usdc/FiatToken/centre-tokens/contracts/v2/FiatTokenV2_2.sol";

contract USDCTest is ERC20GasProfileBase {
    FiatTokenProxy proxyContract;
    FiatTokenV2_2 fiatTokenV2_2;
    address Deployer;
    address proxyOwner; // aka proxy admin too !
    address minterRoleConfigurator; // The one who configures who can mint

    // Dummy for implementation storage setting
    address THROWAWAY_ADDRESS = 0x0000000000000000000000000000000000000001;

    string constant NAME = "USD Coin";
    string constant SYMBOL = "USDC";
    string constant CURRENCY = "USD";
    uint8 constant DECIMALS = 6;
    address erc20Vault; //"mock" erc20 vault

    function setUp() external {
        Deployer = vm.addr(0x1);
        proxyOwner = vm.addr(0x2);
        minterRoleConfigurator = vm.addr(0x3);
        erc20Vault = vm.addr(0x4);

        vm.startPrank(Deployer);
        fiatTokenV2_2 = new FiatTokenV2_2();
        proxyContract = new FiatTokenProxy(address(fiatTokenV2_2));

        //// These values are dummy values because we only rely on the implementation
        //// deployment for delegatecall logic, not for actual state storage.
        fiatTokenV2_2.initialize(
            "",
            "",
            "",
            0,
            THROWAWAY_ADDRESS,
            THROWAWAY_ADDRESS,
            THROWAWAY_ADDRESS,
            THROWAWAY_ADDRESS
        );
        fiatTokenV2_2.initializeV2("");
        fiatTokenV2_2.initializeV2_1(THROWAWAY_ADDRESS);
        fiatTokenV2_2.initializeV2_2(new address[](0), SYMBOL);

        //// Do the initial (V1) initialization.
        //// Note that this takes in the master minter contract's address as the master minter.
        //// The master minter contract's owner is a separate address.
        vm.stopPrank();

        vm.startPrank(proxyOwner);
        (, bytes memory retVal) = address(proxyContract).call(
            abi.encodeWithSelector(
                FiatTokenV1.initialize.selector,
                NAME,
                SYMBOL,
                CURRENCY,
                DECIMALS,
                minterRoleConfigurator,
                THROWAWAY_ADDRESS,
                THROWAWAY_ADDRESS,
                proxyOwner
            )
        );

        //// Do the V2 initialization
        // console.log("Initializing V2...");
        (, retVal) = address(proxyContract).call(
            abi.encodeWithSelector(FiatTokenV2.initializeV2.selector, NAME)
        );

        // // Do the V2_1 initialization
        // console.log("Initializing V2.1...");
        (, retVal) = address(proxyContract).call(
            abi.encodeWithSelector(
                FiatTokenV2_1.initializeV2_1.selector,
                THROWAWAY_ADDRESS
            )
        );

        // // Do the V2_2 initialization
        // console.log("Initializing V2.2...");
        (, retVal) = address(proxyContract).call(
            abi.encodeWithSelector(
                FiatTokenV2_2.initializeV2_2.selector,
                new address[](0),
                SYMBOL
            )
        );

        vm.stopPrank();

        vm.prank(minterRoleConfigurator, minterRoleConfigurator);
        (, retVal) = address(proxyContract).call(
            abi.encodeWithSelector(
                FiatTokenV1.configureMinter.selector,
                erc20Vault,
                type(uint256).max
            )
        );

        // Mint 10 tokens to Alice
        vm.prank(erc20Vault, erc20Vault);
        (, retVal) = address(proxyContract).call(
            abi.encodeWithSelector(
                FiatTokenV1.mint.selector,
                sender,
                mintAmount
            )
        );

        initializeTest("USDC");
    }

    function erc20Transfer() internal override {
        address(proxyContract).call(
            abi.encodeWithSelector(
                FiatTokenV1.transfer.selector,
                recipient,
                transferAmount
            )
        );
    }
}
