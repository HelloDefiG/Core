// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
interface INFT is IERC721{
    function powerOf(uint256 tokenId) external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}