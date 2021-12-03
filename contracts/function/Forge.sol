// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../supplementary/IMaterial.sol";
import "../IMBxOC.sol";
import "../IDFG.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../helper/PRNG.sol";

contract Forge is Ownable {
    using SafeMath for uint256;

    address private _recipient;
    uint256 private _balance;
    uint256 private _price;
    address private _materialAddress;
    address private _coinAddres;
    address private _nftAddress;

    mapping(uint256 => uint256) private _upgradeCount;
    mapping(string => uint256[]) private _costMaterial;
    uint16[14] private _upgradeProbability;

    event UpgradeTo(
        uint256 indexed tokenId,
        address indexed owner,
        uint256[] ids,
        uint256[] amounts,
        uint256[3] upLevels,
        bool result
    );

    constructor(
        address recipient,
        address material,
        address nft,
        address coin
    ) Ownable() {
        require(
            recipient != address(0),
            "Forge: The 'recipient' is a zero address"
        );
        require(
            material != address(0),
            "Forge: The 'material' is a zero address"
        );
        require(
            nft != address(0),
            "Forge: The 'nft' is a zero address"
        );
        require(
            coin != address(0),
            "Forge: The 'coin' is a zero address"
        );
        _recipient = recipient;
        _materialAddress = material;
        _coinAddres = coin;
        _nftAddress = nft;
        _initCostMaterial();
    }

    function balanceOf() public view returns (uint256) {
        return _balance;
    }

    function setPrice(uint256 price) public onlyOwner {
        _price = price;
    }

    function getPrice() public view returns (uint256) {
        return _price;
    }

    function upgradeCount(uint256 tokenId) public view returns (uint256) {
        return _upgradeCount[tokenId];
    }

    function up(
        uint256 tokenId,
        uint256[3] memory upLevels,
        uint256[] memory upIds,
        uint256[] memory amounts
    ) public {
        uint256[5] memory ids = _parseTokenId(tokenId);
        require(
            ids[0] > 0 && ids[1] > 0 && ids[2] > 0 && ids[3] > 0 && ids[4] > 0,
            "Forge: The tokenId is not legal"
        );
        require(
            IMBxOC(_nftAddress).ownerOf(tokenId) == _msgSender(),
            "Forge: caller is not owner of the MBxOC"
        );
        require(_upgradeCount[tokenId] < 13, "Forge: Upgrade limit exceeded");
        uint256 mbcBalance = IDFG(_coinAddres).balanceOf(_msgSender());
        require(mbcBalance >= _price, "Forge: DFG balance less than price");
        uint256 index = 0;
        uint256 cost = 0;
        uint256 sid;
        uint256 level;
        for (uint256 i = 0; i < 3; i++) {
            if (upLevels[i] > 0) {
                level = upLevels[i];
                cost = 0;
                if (i == 0 && level < 7) {
                    cost = _costMaterial["pet"][level];
                    sid = ids[1];
                } else if (i == 1 && level < 13) {
                    cost = _costMaterial["weapon"][level];
                    sid = ids[3];
                } else if (i == 2 && level < 7) {
                    cost = _costMaterial["wing"][level];
                    sid = ids[4];
                }
                require(
                    cost > 0 && upIds[index] == sid && amounts[index] == cost,
                    "Forge: materials mismatch"
                );
                index++;
            }
        }
        require(level > 0, "Forge: Param 'upLevels' is wrong");
        _upgradeCount[tokenId]++;
        IDFG(_coinAddres).transferFrom(_msgSender(), _recipient, _price);
        IMaterial(_materialAddress).safeBatchTransferFrom(
            _msgSender(),
            _recipient,
            upIds,
            amounts,
            ""
        );
        bool result = PRNG.probability(tokenId, _upgradeProbability[level]);
        if (result) {
            IMBxOC(_nftAddress).upgrade(tokenId, upLevels);
        }

        emit UpgradeTo(tokenId, _msgSender(), upIds, amounts, upLevels, result);
    }

    function _initCostMaterial() private {
        _costMaterial["pet"] = [0, 1, 2, 3, 4, 4, 5];
        _costMaterial["weapon"] = [
            0,
            10,
            15,
            20,
            25,
            30,
            35,
            40,
            45,
            50,
            55,
            60,
            65
        ];
        _costMaterial["wing"] = [0, 1, 2, 3, 4, 4, 5];
        _upgradeProbability = [
            0,
            9000,
            8500,
            8000,
            7500,
            7000,
            6500,
            6000,
            5500,
            5000,
            4500,
            4000,
            3500
        ];
    }

    function _parseTokenId(uint256 tokenId)
        private
        pure
        returns (uint256[5] memory)
    {
        uint256[5] memory ids;
        uint256 sid = tokenId.div(1000000000000000000000000);
        uint256 mod = tokenId.mod(1000000000000000000000000);
        if (sid != 404021 && sid != 404038 && sid != 404034 && sid != 404028) {
            return ids;
        }
        ids[0] = sid;
        sid = mod.div(1000000000000000000);
        mod = mod.mod(1000000000000000000);
        if (
            sid != 400035 &&
            sid != 400036 &&
            sid != 400045 &&
            sid != 400043 &&
            sid != 400048 &&
            sid != 400039 &&
            sid != 400041 &&
            sid != 400010
        ) {
            return ids;
        }
        ids[1] = sid;
        sid = mod.div(1000000000000);
        mod = mod.mod(1000000000000);

        if (
            sid != 111005 &&
            sid != 111006 &&
            sid != 111007 &&
            sid != 111008 &&
            sid != 111009 &&
            sid != 111012 &&
            sid != 111014 &&
            sid != 111015 &&
            sid != 111016 &&
            sid != 111019 &&
            sid != 111020 &&
            sid != 111021 &&
            sid != 111505 &&
            sid != 111506 &&
            sid != 111507 &&
            sid != 111508 &&
            sid != 111509 &&
            sid != 111583 &&
            sid != 111514 &&
            sid != 111515 &&
            sid != 111516 &&
            sid != 111519 &&
            sid != 111520 &&
            sid != 111521
        ) {
            return ids;
        }
        ids[2] = sid;
        sid = mod.div(1000000);
        mod = mod.mod(1000000);
        if (sid != 600021 && sid != 600008 && sid != 600006) {
            return ids;
        }
        ids[3] = sid;
        if (mod != 501014 && mod != 501012 && mod != 501013) {
            return ids;
        }
        ids[4] = mod;
        return ids;
    }
}
