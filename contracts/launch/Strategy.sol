// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../helper/LaunchBase.sol";

contract Strategy is LaunchBase{
    constructor(address account,
        address dfgAddress)LaunchBase(account,dfgAddress, 360, 360, 0){
    }
}