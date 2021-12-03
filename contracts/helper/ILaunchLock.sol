// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILaunchLock {
    function lockOf(address owner) external view returns(uint256);
}
