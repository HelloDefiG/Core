// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILaunchBase {
    function init(uint256 total) external;

    function launch() external;
}
