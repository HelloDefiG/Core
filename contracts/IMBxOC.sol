// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./helper/INFTControl.sol";

interface IMBxOC is INFTControl{
    function tokenURI(uint256 tokenId) external view returns (string memory);
}