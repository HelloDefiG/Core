// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../helper/LaunchBase.sol";

contract Team is LaunchBase{
    constructor(address account,
        address dfgAddress)LaunchBase(account,dfgAddress, 360, 1080, 0){
    }
}