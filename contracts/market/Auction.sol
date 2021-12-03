// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./helper/ServiceFee.sol";
import "./helper/Slice.sol";
import "../../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Auction is ServiceFee, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public turnover;
    uint256 public commission;
    uint256 public dealedTimes;

    uint256 private _auctionId;
    uint256 private _bidHistoryId;
    mapping(uint256 => AuctionItem) private _auctionItems;
    mapping(uint256 => BidHistory) private _bidHistorys;
    mapping(uint256 => uint256) private _increaseTimes;
    mapping(uint256 => uint256) private _publisherProfits;

    mapping(address => uint256[]) private _publisherToAuction;
    mapping(address => uint256[]) private _auctioning;
    mapping(address => uint256[]) private _auctioned;
    uint256 private _updatedIndex;
    Update[5] private _updated;

    mapping(uint256 => uint256[]) private _itemBidHistory;
    mapping(address => uint256[]) private _biderToHistorys;
    struct AuctionItem {
        uint256 id;
        address nftAddress;
        address publisher;
        uint256 startPrice;
        address bidder;
        uint256 bidPrice;
        uint256 startTime;
        uint256 endTime;
        string tokenURI;
        uint256 hashRate;
        uint256 index;
        bool finished;
        uint256 profits;
        uint256 nextPrice;
        uint256 tokenId;
    }

    struct BidHistory {
        address bidder;
        uint256 bidPrice;
        uint256 bidTime;
        uint256 profits;
        uint256 auctionId;
    }

    struct Update {
        address nftAddress;
        uint256 updateType; //0: publish 1: bid 2: end
        uint256 auctionId;
        uint256 updateTime;
    }

    event Publish(
        uint256 auctionId,
        address indexed publisher,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 startPric
    );
    event Bid(address indexed bidder, uint256 indexed auctionId, uint256 price);
    event ReceiveNFT(
        address indexed publisher,
        address indexed winner,
        uint256 indexed auctionId,
        uint256 lastPrice
    );

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

    function blockTimeStamp() external view returns (uint256) {
        return block.timestamp;
    }

    function total() external view returns (uint256) {
        return _auctionId;
    }

    function auctionItem(uint256 auctionId)
        external
        view
        returns (AuctionItem memory)
    {
        return _auctionItems[auctionId];
    }

    function auctionOfPublisher(address publisher)
        external
        view
        returns (uint256[] memory)
    {
        return _publisherToAuction[publisher];
    }

    function historyOf(address bidder)
        external
        view
        returns (uint256[] memory)
    {
        return _biderToHistorys[bidder];
    }

    function bidHistory(uint256 bidHistoryId)
        external
        view
        returns (BidHistory memory)
    {
        return _bidHistorys[bidHistoryId];
    }

    function bidOfAuction(uint256 auctionId)
        external
        view
        returns (uint256[] memory)
    {
        return _itemBidHistory[auctionId];
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

    function auctionEndCount(address nftAddress)
        external
        view
        returns (uint256)
    {
        return _auctioned[nftAddress].length;
    }

    function listByNFTType(
        address nftAddress,
        uint256 start,
        uint256 size
    ) external view returns (uint256[] memory) {
        return Slice.uint256Array(_auctioning[nftAddress], start, size);
    }

    function listEndByNFTType(
        address nftAddress,
        uint256 start,
        uint256 size
    ) external view returns (uint256[] memory) {
        return Slice.uint256Array(_auctioned[nftAddress], start, size);
    }

    function publish(
        address nftAddress,
        uint256 startPrice,
        uint256 tokenId,
        uint256 time
    ) external nonReentrant {
        require(
            INFT(nftAddress).ownerOf(tokenId) == _msgSender(),
            "Auction: NFT's owner isn't publisher"
        );
        require(
            startPrice > 1e18,
            "Auction: 'startPrice' must be at least 1.0 DFG"
        );
        INFT(nftAddress).safeTransferFrom(_msgSender(), address(this), tokenId);
        string memory tokenURI = INFT(nftAddress).tokenURI(tokenId);
        uint256 hashRate = INFT(nftAddress).powerOf(tokenId);
        uint256 id = _auctionId;
        uint256 index = _auctioning[nftAddress].length;
        _auctionId++;
        _beforePublish(id, nftAddress);
        _auctionItems[id] = AuctionItem(
            id,
            nftAddress,
            _msgSender(),
            startPrice,
            address(0),
            0,
            block.timestamp,
            block.timestamp + time.mul(3600),
            tokenURI,
            hashRate,
            index,
            false,
            0,
            startPrice,
            tokenId
        );
        _publisherToAuction[_msgSender()].push(id);
        emit Publish(id, _msgSender(), nftAddress, tokenId, startPrice);
    }

    function bid(uint256 auctionId) external nonReentrant {
        require(
            _auctionItems[auctionId].startTime != 0,
            "Auction: bid to nonexistent auction"
        );
        require(
            _auctionItems[auctionId].publisher != _msgSender(),
            "Auction: Publisher can't bid"
        );
        require(
            block.timestamp < _auctionItems[auctionId].endTime,
            "Auction: Bidding time has passed"
        );
        uint256 latestPrice = _auctionItems[auctionId].startPrice;
        uint256 nextPrice = _auctionItems[auctionId].nextPrice;
        uint256 sub;
        uint256 rebate; // 10% * 20% * 80%
        uint256 profits; // 10% * 20%
        uint256 fee; // 10% * 20% * 20%
        string memory err = "Auction: Calculation error";
        uint256 balanceDFG = IDFG(_dfgAddress).balanceOf(_msgSender());
        uint256 bidHistoryId = _bidHistoryId;
        require(balanceDFG >= nextPrice, "Auction: Insufficient DFG balance");

        if (_auctionItems[auctionId].bidder != address(0)) {
            latestPrice = _auctionItems[auctionId].bidPrice;
            sub = nextPrice.sub(latestPrice, err);
            rebate = sub.mul(20).div(100, err);
            profits = rebate;
            fee = profits.mul(20).div(100, err);
            rebate = profits.sub(fee, err);
            commission = commission.add(profits);
        }
        IDFG(_dfgAddress).transferFrom(_msgSender(), address(this), nextPrice);
        if (_auctionItems[auctionId].bidder != address(0)) {
            _dealServiceFee(fee, _auctionItems[auctionId].nftAddress);
            IDFG(_dfgAddress).transfer(
                _auctionItems[auctionId].bidder,
                latestPrice.add(rebate)
            );
            _calcPublisherprofits(
                auctionId,
                profits,
                rebate,
                latestPrice,
                nextPrice
            );
        } else {
            _publisherProfits[auctionId] = nextPrice;
        }
        _bidHistoryId++;
        _itemBidHistory[auctionId].push(bidHistoryId);
        _biderToHistorys[_msgSender()].push(bidHistoryId);
        _bidHistorys[bidHistoryId] = BidHistory(
            _msgSender(),
            nextPrice,
            block.timestamp,
            0,
            auctionId
        );
        _setUpdate(1, _auctionItems[auctionId].nftAddress, auctionId);

        _auctionItems[auctionId].bidder = _msgSender();
        _auctionItems[auctionId].bidPrice = nextPrice;
        _auctionItems[auctionId].profits = profits;
        if (
            _increaseTimes[auctionId] < 6 &&
            _auctionItems[auctionId].endTime - block.timestamp < 3600
        ) {
            _auctionItems[auctionId].endTime += 600;
            _increaseTimes[auctionId] += 1;
        }
        _auctionItems[auctionId].nextPrice = nextPrice.mul(110).div(100, err);
    }

    function receiveNFT(uint256 auctionId) external nonReentrant {
        require(
            _auctionItems[auctionId].startTime != 0,
            "Auction: end to nonexistent auction"
        );
        require(
            !_auctionItems[auctionId].finished,
            "Auction: The bidding is over"
        );
        require(
            block.timestamp > _auctionItems[auctionId].endTime,
            "Auction: Bidding in progress"
        );
        address owner = _auctionItems[auctionId].bidder;
        uint256 all = _publisherProfits[auctionId];
        uint256 fee;
        if (owner == address(0)) {
            owner = _auctionItems[auctionId].publisher;
        }
        require(
            _msgSender() == owner,
            "Auction: The caller must be the last owner"
        );
        require(
            _auctionItems[auctionId].bidder == address(0) || all > 0,
            "Auction: The bidding is over"
        );
        _publisherProfits[auctionId] = 0;
        _beforeReceive(
            _auctionItems[auctionId].nftAddress,
            _auctionItems[auctionId].index,
            auctionId
        );
        _auctionItems[auctionId].finished = true;
        if (_auctionItems[auctionId].bidder != address(0)) {
            dealedTimes += 1;
            turnover = turnover.add(_auctionItems[auctionId].bidPrice);
            fee = all.mul(3).div(100, "Auction: Calculation error");
            _dealServiceFee(fee, _auctionItems[auctionId].nftAddress);
            IDFG(_dfgAddress).transfer(
                _auctionItems[auctionId].publisher,
                all.sub(fee, "Auction: Calculation error")
            );
        }
        INFT(_auctionItems[auctionId].nftAddress).safeTransferFrom(
            address(this),
            owner,
            _auctionItems[auctionId].tokenId
        );
        emit ReceiveNFT(
            _auctionItems[auctionId].publisher,
            _auctionItems[auctionId].bidder,
            auctionId,
            _auctionItems[auctionId].bidPrice
        );
    }

    function _calcPublisherprofits(
        uint256 auctionId,
        uint256 prevRebate,
        uint256 prevProfits,
        uint256 prevPrice,
        uint256 nextPrice
    ) private {
        uint256 lastHistory = _itemBidHistory[auctionId].length - 1;
        uint256 newProfits = _publisherProfits[auctionId];
        lastHistory = _itemBidHistory[auctionId][lastHistory];
        _bidHistorys[lastHistory].profits = prevProfits;
        newProfits = newProfits.add(nextPrice);
        newProfits = newProfits.sub(prevRebate, "Auction: Calculation error");
        newProfits = newProfits.sub(prevPrice, "Auction: Calculation error");
        _publisherProfits[auctionId] = newProfits;
    }

    function _beforePublish(uint256 auctionId, address nftAddress) private {
        _auctioning[nftAddress].push(auctionId);
        _setUpdate(0, nftAddress, auctionId);
    }

    function _beforeReceive(
        address nftAddress,
        uint256 index,
        uint256 auctionId
    ) private {
        uint256 lastIndex = _auctioning[nftAddress].length - 1;
        uint256 lastId = _auctioning[nftAddress][lastIndex];
        if (_auctionItems[lastId].id != auctionId) {
            _auctioning[nftAddress][index] = lastId;
            _auctioning[nftAddress][lastIndex] = auctionId;

            _auctionItems[lastId].index = index;
        }
        _auctioned[nftAddress].push(auctionId);
        _auctioning[nftAddress].pop();
        _setUpdate(2, nftAddress, auctionId);
    }

    function _setUpdate(
        uint256 _type,
        address nftAddress,
        uint256 auctionId
    ) private {
        uint256 index = _updatedIndex;
        if (index < 4) {
            _updatedIndex = index + 1;
        } else {
            _updatedIndex = 0;
        }
        _updated[index] = Update(nftAddress, _type, auctionId, block.timestamp);
    }
}
