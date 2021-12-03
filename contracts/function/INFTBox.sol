// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../helper/IOwnable.sol";

interface INFTBox is IOwnable {
    struct MintItem {
        address nftContract;
        uint256 tokenId;
        address owner;
        uint256 price;
    }
    function minted()external view returns(uint256[] memory);

    function mintRecord(uint256 tokenId) external view returns (MintItem memory);
    function balanceOf() external view returns (uint256);

    function setNftTypePrice(uint256 nftType, uint256 price) external;
    function getNftTypePrice(uint256 nftType) external view returns (uint256);

    function setNftTypeSupply(uint256 nftType, uint256 count) external;

    function getNftTypeSupply(uint256 nftType) external view returns (uint256);

    function getNftTypeCount(uint256 nftType) external view returns (uint256);
    function mint(
        address nftContract,
        uint256 tokenId
    ) external payable;
}
