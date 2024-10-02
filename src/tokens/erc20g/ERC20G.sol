// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlDefaultAdminRulesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interfaces/ITransferEventHandler.sol";
import "./interfaces/IFeeReceiver.sol";
import {ERC3009Upgradeable} from "./extensions/ERC3009Upgradeable.sol";

contract ERC20G is
    Initializable,
    ERC20Upgradeable,
    PausableUpgradeable,
    AccessControlDefaultAdminRulesUpgradeable,
    ERC3009Upgradeable
{
    /// @custom:storage-location erc7201:gu-corp.storage.ERC20G
    struct ERC20GStorage {
        uint8 _decimals;
        string _info;
        ITransferEventHandler transferEventHandler;
        IFeeReceiver feeReceiver;
    }

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // keccak256(abi.encode(uint256(keccak256("gu-corp.storage.ERC20G")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20GStorageLocation =
        0x4b126b387a4e21d545a94fbe1b63c04b6e530e91ab10285bf0d19faf14c08500;

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint48 initialDelay_
    ) external initializer {
        __ERC20G_init(name_, symbol_, decimals_, initialDelay_);
    }

    function __ERC20G_init(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint48 initialDelay_
    ) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
        __EIP712_init_unchained(name_, "1");
        __Pausable_init_unchained();
        __ERC20G_init_unchained(decimals_);
        __AccessControlDefaultAdminRules_init_unchained(
            initialDelay_,
            _msgSender()
        );
    }

    function __ERC20G_init_unchained(
        uint8 decimals_
    ) internal onlyInitializing {
        ERC20GStorage storage $ = _getERC20GStorage();

        $._decimals = decimals_;

        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    function info() public view virtual returns (string memory) {
        ERC20GStorage storage $ = _getERC20GStorage();
        return $._info;
    }

    function setInfo(
        string memory newInfo
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC20GStorage storage $ = _getERC20GStorage();
        $._info = newInfo;
    }

    function decimals() public view virtual override returns (uint8) {
        ERC20GStorage storage $ = _getERC20GStorage();
        return $._decimals;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(to, amount);
    }

    function transferEventHandler() public view returns (address) {
        ERC20GStorage storage $ = _getERC20GStorage();
        return address($.transferEventHandler);
    }

    function setTransferEventHandler(
        ITransferEventHandler _transferEventHandler
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC20GStorage storage $ = _getERC20GStorage();
        $.transferEventHandler = _transferEventHandler;
    }

    function feeReceiver() public view returns (address) {
        ERC20GStorage storage $ = _getERC20GStorage();
        return address($.feeReceiver);
    }

    function setFeeReceiver(
        IFeeReceiver _feeReceiver
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _feeReceiver.canReceiveToken(address(this)),
            "Fee receiver cannot accept this token"
        );
        ERC20GStorage storage $ = _getERC20GStorage();
        $.feeReceiver = _feeReceiver;
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        bool isOperator = (hasRole(OPERATOR_ROLE, _msgSender()) ||
            from == address(0) ||
            to == address(0));

        ERC20GStorage storage $ = _getERC20GStorage();

        if (address($.transferEventHandler) != address(0)) {
            $.transferEventHandler.onBeforeTransfer(
                from,
                to,
                amount,
                _msgSender()
            );
        }
        if (address($.feeReceiver) != address(0) && !isOperator) {
            uint256 fee = $.feeReceiver.calculateFee(from, to, amount);

            if (fee > 0) {
                super._update(from, address($.feeReceiver), fee);
                amount -= fee;
            }
        }
        super._update(from, to, amount);
        if (address($.transferEventHandler) != address(0)) {
            $.transferEventHandler.onAfterTransfer(
                from,
                to,
                amount,
                _msgSender()
            );
        }
    }

    function operatorSend(
        address from,
        address to,
        uint256 amount
    ) public onlyRole(OPERATOR_ROLE) returns (bool) {
        _transfer(from, to, amount);
        return true;
    }

    function _getERC20GStorage()
        private
        pure
        returns (ERC20GStorage storage $)
    {
        assembly {
            $.slot := ERC20GStorageLocation
        }
    }
}
