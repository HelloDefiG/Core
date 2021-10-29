// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../helper/LaunchBase.sol";

contract Advisor is LaunchBase{
    constructor(address account,
        address dfgAddress)LaunchBase(account,dfgAddress, 360, 720, 0){
    }
}