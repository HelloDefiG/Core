// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./RoleControl.sol";
import "./PRNG.sol";

abstract contract NFTControl is ERC721Enumerable, RoleControl {
    using SafeMath for uint256;

    mapping(uint256 => uint256[5]) private _tokenLevels;
    mapping(uint256 => uint256) private _tokenPower;

    uint256[5] private _partRate = [10, 50, 10, 20, 10];
    uint256[13] private _multiplyRate = [
        1,
        2,
        4,
        7,
        11,
        16,
        22,
        29,
        37,
        46,
        56,
        67,
        79
    ];

    function powerOf(uint256 tokenId) public view returns (uint256) {
        return _tokenPower[tokenId];
    }

    function mint(address to, uint256 tokenId) public {
        require(
            owner() == _msgSender() || getRoleApproved("mint", _msgSender()),
            "MBxOC: The caller is not admin nor approved"
        );
        require(_checkTokenIdLegal(tokenId), "MBxOC: The tokenId is not legal");
        _safeMint(to, tokenId);
    }

    function upgrade(uint256 tokenId, uint256[3] memory upLevels) public {
        require(
            owner() == _msgSender() || getRoleApproved("upgrade", _msgSender()),
            "MBxOC: The caller is not admin nor approved"
        );

        uint256 level1 = _tokenLevels[tokenId][1];
        uint256 level2 = _tokenLevels[tokenId][3];
        uint256 level3 = _tokenLevels[tokenId][4];
        require(
            level2 < 13,
            "MBxOC: The NFT is full level"
        );
        if(upLevels[0] > 0){
            require(
                upLevels[0] == level1,
                "MBxOC: Target level is wrong"
            );
            level1 += 1;
            _tokenLevels[tokenId][1] = level1;
        }
        if(upLevels[1] > 0){
            require(
                upLevels[1] == level2,
                "MBxOC: Target level is wrong"
            );
            level2 += 1;
            _tokenLevels[tokenId][3] = level2;
        }
        if(upLevels[2] > 0){
            require(
                upLevels[2] == level3,
                "MBxOC: Target level is wrong"
            );
            level3 += 1;
            _tokenLevels[tokenId][4] = level3;
        }
        require(
            level2 <= 13 && level2 >= level1 && level1 <= 7 &&  level3 <= 7 && level1 == level3,
            "MBxOC: Target level is wrong"
        );
        
        _tokenPower[tokenId] = _calcTokenPower(_tokenLevels[tokenId]);
    }
    function getLevel(uint256 tokenId) public view returns(uint256[5] memory){
        require(_exists(tokenId), "MBxOC: NONEXISTENT_TOKEN");
        return _tokenLevels[tokenId];
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (from == address(0)) {
            _tokenLevels[tokenId] = [
                1,
                PRNG.probability(tokenId, 5000) ? 2 : 1,
                1,
                PRNG.probability(tokenId + 1, 5000) ? 2 : 1,
                PRNG.probability(tokenId + 2, 5000) ? 2 : 1
            ];
            _tokenPower[tokenId] = _calcTokenPower(_tokenLevels[tokenId]);
        }
    }

    function _checkTokenIdLegal(uint256 tokenId) private pure returns (bool) {
        uint256 sid = tokenId.div(1000000000000000000000000);
        uint256 mod = tokenId.mod(1000000000000000000000000);
        if (sid != 404021 && sid != 404038 && sid != 404034 && sid != 404028) {
            return false;
        }
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
            return false;
        }
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
            return false;
        }
        sid = mod.div(1000000);
        mod = mod.mod(1000000);
        if (sid != 600021 && sid != 600008 && sid != 600006) {
            return false;
        }
        if (mod != 501014 && mod != 501012 && mod != 501013) {
            return false;
        }
        return true;
    }

    function _calcTokenPower(uint256[5] memory levels)
        private
        view
        returns (uint256)
    {
        uint256 hashRate = 20;
        hashRate += _multiplyRate[levels[1] - 1] * _partRate[1];
        hashRate += _multiplyRate[levels[3] - 1] * _partRate[3];
        hashRate += _multiplyRate[levels[4] - 1] * _partRate[4];
        return hashRate;
    }
}
