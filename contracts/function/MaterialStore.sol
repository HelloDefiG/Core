// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../supplementary/IMaterial.sol";
import "../IDFG.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MaterialStore is Ownable {
    using SafeMath for uint256;

    address private _recipient;
    uint256 private _balance;
    address private _materialAddress;
    address private _coinAddres;
    
    event BuyMaterial(
        address indexed owner,
        uint256[] ids,
        uint256[] amounts,
        uint256 spend
    );
    constructor(address recipient,address material, address coin)Ownable(){
        require(
            recipient != address(0),
            "MaterialStore: The 'recipient' is a zero address"
        );
        require(
            material != address(0),
            "MaterialStore: The 'material' is a zero address"
        );
        require(
            coin != address(0),
            "MaterialStore: The 'coin' is a zero address"
        );
        _recipient = recipient;
        _materialAddress = material;
        _coinAddres = coin;
    }

    function balanceOf() public view returns (uint256) {
        return _balance;
    }

    function buy(uint256[] memory ids, uint256[] memory amounts)public{
        require(
            ids.length > 0,
            "MaterialStore: The purchased material must be selected"
        );
        require(
            ids.length == amounts.length,
            "MaterialStore: ids and amounts length mismatch"
        );
        
        uint256 cost = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            uint256 _price = _getprice(ids[i]);
            require(
                _price > 0,
                "MaterialStore: id is wrong"
            );
            cost += amounts[i]*_price;
        }
        require(
            IDFG(_coinAddres).balanceOf(_msgSender()) >= cost,
            "MaterialStore: DFG balance less than cost"
        );
        _balance += cost;
        IDFG(_coinAddres).transferFrom(_msgSender(), _recipient, cost);
        IMaterial(_materialAddress).mintBatch(_msgSender(), ids, amounts);
        emit BuyMaterial(
            _msgSender(),
            ids,
            amounts,
            cost
        );
    }
    function _getprice(uint256 sid) private pure returns(uint256){
        if (
            sid == 400035 ||
            sid == 400036 ||
            sid == 400045 ||
            sid == 400043 ||
            sid == 400048 ||
            sid == 400039 ||
            sid == 400041 ||
            sid == 400010 ||
            sid == 501014 || 
            sid == 501012 || 
            sid == 501013
        ) {
            return 1500 * 1e18;
        }else if(sid == 600021 || sid == 600008 || sid == 600006){
            return 100 * 1e18;
        }else{
            return 0;
        }
    }
}
