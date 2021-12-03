// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../helper/RoleControl.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Material is ERC1155, RoleControl{

    constructor(string memory uri_)ERC1155(uri_)Ownable() {
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount
    )public{
        require(
            owner() == _msgSender() || getRoleApproved("mint", _msgSender()),
            "Material: The caller must be admin or approved"
        );
        _mint(to, id, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    )public{
        require(
            owner() == _msgSender() || getRoleApproved("mint", _msgSender()),
            "Material: The caller must be admin or approved"
        );
        _mintBatch(to, ids, amounts, "");
    }
}
