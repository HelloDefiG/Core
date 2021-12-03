// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./helper/IOwnable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./helper/ILaunchLock.sol";

interface IDFG is IERC20, IOwnable,ILaunchLock{
    function setWhite(address owner, bool isWhite)external;
    function whiteOf(address owner) external view returns(bool);
    function launchAdvisor(address recipient, uint256 amount) external;
    function launchStrategy(address recipient, uint256 amount) external;
    function initSupply(
        address _ecosystemFund,
        address _playtoEarn,
        address _nftMining,
        address _marketing,
        address _team,
        address _public
    ) external;
}
