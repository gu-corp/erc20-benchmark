// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IFeeReceiver {
    function canReceiveToken(address token) external view returns (bool);

    function calculateFee(
        address from,
        address to,
        uint256 amount
    ) external view returns (uint256);
}
