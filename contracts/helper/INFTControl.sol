// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./IRoleControl.sol";
interface INFTControl is IERC721Enumerable, IRoleControl{
    function powerOf(uint256 tokenId) external view returns (uint256);
    function mint(address to, uint256 tokenId)external;
    function upgrade(uint256 tokenId, uint256[3] memory upLevels) external; 
    function getLevel(uint256 tokenId) external view returns(uint256[5] memory);
}