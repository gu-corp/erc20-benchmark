// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITransferEventHandler {
    function setCaller(address newCaller) external;

    function onBeforeTransfer(
        address from,
        address to,
        uint256 amount,
        address msgSender
    ) external view returns (bool);

    function onAfterTransfer(
        address from,
        address to,
        uint256 amount,
        address msgSender
    ) external returns (bool);
}
