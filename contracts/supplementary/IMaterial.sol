// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../helper/IRoleControl.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IMaterial is IERC1155, IRoleControl{

    function mint(
        address account,
        uint256 id,
        uint256 amount
    )external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    )external;
}
