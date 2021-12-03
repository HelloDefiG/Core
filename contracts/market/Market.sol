// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./helper/ServiceFee.sol";
import "./helper/Slice.sol";
import "../../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Market is ServiceFee, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public turnover;
    uint256 public dealedTimes;

    uint256 private _marketId;
    mapping(uint256 => MarketItem) private _marketItems;
    mapping(address => uint256[]) private _selling;
    mapping(address => uint256[]) private _end;
    mapping(address => uint256[]) private _publisherToHistorys;
    mapping(address => uint256[]) private _buyerToHistorys;
    uint256 private _updatedIndex;
    Update[5] private _updated;

    struct MarketItem {
        uint256 id;
        address nftAddress;
        address publisher;
        uint256 tokenId;
        string tokenURI;
        uint256 hashRate;
        uint256 price;
        uint256 status; // 0: selling; 1: sold; 2: cancel
        uint256 index;
        address purchaser;
        uint256 time;
    }

    struct Update {
        address nftAddress;
        uint256 updateType; //0: publish 1: sold 2: cancel
        uint256 marketId;
        uint256 updateTime;
    }

    event Publish(
        address indexed publisher,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 marketId,
        uint256 price
    );

    event Sold(address purchaser, uint256 marketId, uint256 price);

    constructor(
        address dfgAddress,
        address marketingAddress,
        address nftMiningAddress
    ) ServiceFee(dfgAddress, marketingAddress, nftMiningAddress) {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function total() external view returns (uint256) {
        return _marketId;
    }

    function marketItem(uint256 marketId)
        external
        view
        returns (MarketItem memory)
    {
        return _marketItems[marketId];
    }

    function getSelling(
        address nftAddress,
        uint256 start,
        uint256 size
    ) external view returns (uint256[] memory) {
        return Slice.uint256Array(_selling[nftAddress], start, size);
    }

    function getEnd(
        address nftAddress,
        uint256 start,
        uint256 size
    ) external view returns (uint256[] memory) {
        return Slice.uint256Array(_end[nftAddress], start, size);
    }

    function getUpdated()
        external
        view
        returns (
            Update memory,
            Update memory,
            Update memory,
            Update memory,
            Update memory
        )
    {
        return (
            _updated[0],
            _updated[1],
            _updated[2],
            _updated[3],
            _updated[4]
        );
    }

    function publishOf(address publisher)
        external
        view
        returns (uint256[] memory)
    {
        return _publisherToHistorys[publisher];
    }

    function buyOf(address buyer) external view returns (uint256[] memory) {
        return _buyerToHistorys[buyer];
    }

    function publish(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant {
        require(
            INFT(nftAddress).ownerOf(tokenId) == _msgSender(),
            "Market: publish of token that is not own"
        );
        require(price > 1e18, "Market: 'price' must be at least 1.0 DFG");
        INFT(nftAddress).safeTransferFrom(_msgSender(), address(this), tokenId);
        string memory tokenURI = INFT(nftAddress).tokenURI(tokenId);
        uint256 hashRate = INFT(nftAddress).powerOf(tokenId);
        uint256 mkId = _marketId;
        uint256 index = _selling[nftAddress].length;
        _marketId++;
        _selling[nftAddress].push(mkId);
        _publisherToHistorys[_msgSender()].push(mkId);
        _setUpdate(0, nftAddress, mkId);
        _marketItems[mkId] = MarketItem(
            mkId,
            nftAddress,
            _msgSender(),
            tokenId,
            tokenURI,
            hashRate,
            price,
            0,
            index,
            address(0),
            block.timestamp
        );
        emit Publish(nftAddress, _msgSender(), tokenId, mkId, price);
    }

    function buy(uint256 marketId) external nonReentrant {
        MarketItem memory item = _marketItems[marketId];
        require(
            item.tokenId != 0,
            "Market: The NFT does not exist in the market"
        );
        require(item.status == 0, "Market: The NFT has not been selling");
        uint256 balanceDFG = IDFG(_dfgAddress).balanceOf(_msgSender());
        uint256 fee;
        require(
            balanceDFG >= item.price,
            "Market: DFG balance is less than the price"
        );
        _setUpdate(1, item.nftAddress, marketId);
        item.index = _beforeBuy(marketId, item.index, item.nftAddress);
        item.status = 1;
        item.purchaser = _msgSender();
        _marketItems[marketId] = item;
        _buyerToHistorys[_msgSender()].push(marketId);
        fee = item.price.mul(3).div(100, "Market: Calculation error");
        turnover = turnover + item.price;
        dealedTimes += 1;
        _dealServiceFeeFrom(_msgSender(), fee, item.nftAddress);
        IDFG(_dfgAddress).transferFrom(
            _msgSender(),
            item.publisher,
            item.price.sub(fee, "Market: Calculation error")
        );
        INFT(item.nftAddress).safeTransferFrom(
            address(this),
            _msgSender(),
            item.tokenId
        );
        emit Sold(_msgSender(), item.id, item.price);
    }

    function cancelSale(uint256 marketId) external nonReentrant {
        MarketItem memory item = _marketItems[marketId];
        require(
            item.tokenId != 0,
            "Market: The NFT does not exist in the market"
        );
        require(item.status == 0, "Market: The NFT has not been selling");
        require(
            _msgSender() == item.publisher,
            "Market: Caller must be publisher"
        );
        _setUpdate(2, item.nftAddress, marketId);
        item.status = 2;
        item.index = _beforeBuy(marketId, item.index, item.nftAddress);
        _marketItems[marketId] = item;
        INFT(item.nftAddress).safeTransferFrom(
            address(this),
            _msgSender(),
            item.tokenId
        );
    }

    function _beforeBuy(
        uint256 marketId,
        uint256 index,
        address nftAddress
    ) private returns (uint256) {
        uint256 lastIndex = _selling[nftAddress].length - 1;
        uint256 lastId = _selling[nftAddress][lastIndex];
        uint256 endIndex = _end[nftAddress].length;
        if (lastId != marketId) {
            _selling[nftAddress][index] = lastId;
            _marketItems[lastId].index = index;
        }
        _end[nftAddress].push(marketId);
        _selling[nftAddress].pop();
        return endIndex;
    }

    function _setUpdate(
        uint256 _type,
        address nftAddress,
        uint256 marketId
    ) private {
        uint256 index = _updatedIndex;
        if (index < 4) {
            _updatedIndex = index + 1;
        } else {
            _updatedIndex = 0;
        }
        _updated[index] = Update(nftAddress, _type, marketId, block.timestamp);
    }
}
