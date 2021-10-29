// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./helper/IOwnable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDFG is IERC20, IOwnable{
    function initSupply(address _teamAddr,
                address _marketingAddr,
                address _ecoFundAddr,
                address _partnersAddr,
                address _playToEarnAddr,
                address _nftPoolAddr,
                address _privateSaleAddr) external;
}
