// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../helper/LaunchBase.sol";

contract Public is LaunchBase{
    constructor(address account,
        address dfgAddress)LaunchBase(account,dfgAddress, 0, 0, 100){
    }
}