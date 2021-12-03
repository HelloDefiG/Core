// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../IDFG.sol";
import "../interface/INFT.sol";
import "../../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../../helper/RoleControl.sol";

abstract contract ServiceFee is RoleControl {
    using SafeMath for uint256;

    address internal _dfgAddress;
    address private _marketingAddress;
    address private _nftMiningAddress;

    mapping(address => address) private _devAddresses;

    constructor(
        address dfgAddress,
        address marketingAddress,
        address nftMiningAddress
    ) Ownable() {
        require(
            dfgAddress != address(0),
            "Auction: The 'dfgAddress' is a zero address"
        );
        require(
            marketingAddress != address(0),
            "Auction: The 'recipient' is a zero address"
        );
        require(
            nftMiningAddress != address(0),
            "Auction: The 'nftMiningAddress' is a zero address"
        );
        _dfgAddress = dfgAddress;
        _marketingAddress = marketingAddress;
        _nftMiningAddress = nftMiningAddress;
    }

    function setMining(address nftMiningAddress) external{
        require(
            _msgSender() == owner() ||
                getRoleApproved("setMinig", _msgSender()),
            "Auction: The caller is not owner nor approved"
        );
        require(
            nftMiningAddress != address(0),
            "Auction: The 'nftMiningAddress' is a zero address"
        );
        _nftMiningAddress = nftMiningAddress;
    }

    function setDeveloper(address nftAddress, address devAddress) external {
        require(
            _msgSender() == owner() ||
                getRoleApproved("setDeveloper", _msgSender()),
            "Auction: The caller is not owner nor approved"
        );
        require(
            nftAddress != address(0),
            "Auction: The 'nftAddress' is a zero address"
        );
        require(
            devAddress != address(0),
            "Auction: The 'devAddress' is a zero address"
        );
        _devAddresses[nftAddress] = devAddress;
    }

    function _dealServiceFee(uint256 fee, address nftAddress) internal {
        uint256 mining = fee.mul(50).div(100);
        uint256 marketing = fee.mul(40).div(100);
        uint256 dev = fee.sub(
            mining.add(marketing),
            "Auction: Calculation error"
        );
        require(
            _devAddresses[nftAddress] != address(0),
            "Auction: The developer is a zero address"
        );
        IDFG(_dfgAddress).transfer(_nftMiningAddress, mining);
        IDFG(_dfgAddress).transfer(_marketingAddress, marketing);
        IDFG(_dfgAddress).transfer(_devAddresses[nftAddress], dev);
    }
    function _dealServiceFeeFrom(address sender,uint256 fee, address nftAddress) internal {
        uint256 mining = fee.mul(50).div(100);
        uint256 marketing = fee.mul(40).div(100);
        uint256 dev = fee.sub(
            mining.add(marketing),
            "Auction: Calculation error"
        );
        require(
            _devAddresses[nftAddress] != address(0),
            "Auction: The developer is a zero address"
        );
        IDFG(_dfgAddress).transferFrom(sender,_nftMiningAddress, mining);
        IDFG(_dfgAddress).transferFrom(sender,_marketingAddress, marketing);
        IDFG(_dfgAddress).transferFrom(sender,_devAddresses[nftAddress], dev);
    }
}
