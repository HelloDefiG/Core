// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IMBxOC.sol";
import "../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract NFTBox is Ownable {
    using SafeMath for uint256;

    address private _recipient;
    uint256 private _balance;
    mapping(uint256 => MintItem) private _tokenIdToMinted;
    
    mapping(uint256 => uint256) private _powerOfPrice;
    
    mapping(uint256 => uint256) private typeOfNFTPrice;
    
    mapping(uint256 => uint256) private _nftTypeCount;
    
    mapping(uint256 => uint256) private _nftTypeSupply;
    uint256[] private _minted;
    
    struct MintItem {
        address nftContract;
        uint256 tokenId;
        address owner;
        uint256 price;
    }
    event Mint(
        address indexed nftContract,
        uint256 indexed tokenId,
        address owner,
        uint256 price
    );
    constructor(address recipient)Ownable(){
        require(
            recipient != address(0),
            "NFTBox: The 'recipient' is a zero address"
        );
        _recipient = recipient;
    }

    function minted()public view returns(uint256[] memory){
        return _minted;
    }

    function mintRecord(uint256 tokenId) public view returns (MintItem memory) {
        return _tokenIdToMinted[tokenId];
    }

    function balanceOf() public view returns (uint256) {
        return _balance;
    }

    function setNftTypePrice(uint256 nftType, uint256 price) public onlyOwner{
        typeOfNFTPrice[nftType] = price;
    }

    function getNftTypePrice(uint256 nftType) public view returns (uint256) {
        return typeOfNFTPrice[nftType];
    }

    function setNftTypeSupply(uint256 nftType, uint256 count) public onlyOwner{
        _nftTypeSupply[nftType] = _nftTypeSupply[nftType] + count;
    }

    function getNftTypeSupply(uint256 nftType) public view returns (uint256) {
        return _nftTypeSupply[nftType];
    }

    function getNftTypeCount(uint256 nftType) public view returns (uint256) {
        return _nftTypeCount[nftType];
    }
    
    function mint(
        address nftContract,
        uint256 tokenId
    ) public payable {
        uint256 nftType = _calcNftType(tokenId);
        uint256 price = typeOfNFTPrice[nftType];
        MintItem memory _mintItem = _tokenIdToMinted[tokenId];
        require(
            _mintItem.owner == address(0),
            "NFTBox: The tokenId has been minted"
        );
        require(
            _nftTypeCount[nftType] < _nftTypeSupply[nftType],
            "NFTBox: MBxOC supply is not enough for the type"
        );
        require(
            msg.value == price,
            "NFTBox: The payment fee is inconsistent with the price"
        );
        _mint(nftContract, tokenId, price, nftType);
    }
    function _calcNftType(uint256 tokenId) private pure returns(uint256) {
        return tokenId.div(1000000000000000000000000);
    }
    function _mint(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 nftType
    )private{
        _tokenIdToMinted[tokenId] = MintItem(
            nftContract,
            tokenId,
            _msgSender(),
            price
        );
        _balance = _balance + msg.value;
        _nftTypeCount[nftType]++;
        _minted.push(tokenId);
        payable(_recipient).transfer(msg.value);
        IMBxOC(nftContract).mint(_msgSender(), tokenId);
        emit Mint(
            nftContract,
            tokenId,
            _msgSender(),
            price
        );
    }
}
