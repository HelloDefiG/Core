// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../helper/LaunchBase.sol";

contract Marketing is LaunchBase{
    constructor(address account,
        address dfgAddress)LaunchBase(account,dfgAddress, 0, 240, 20){
    }
}