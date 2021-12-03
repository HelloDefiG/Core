// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./helper/NFTControl.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MBxOC is NFTControl {
    using Strings for uint256;
    using SafeMath for uint256;

    string private _baseUri;

    constructor(
        string memory baseUri_
    ) ERC721("Mini Battle On Chain", "MBxOC") Ownable() {
        _baseUri = baseUri_;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "MBxOC: NONEXISTENT_TOKEN");

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        tokenId.toString()
                    )
                )
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseUri;
    }
}
