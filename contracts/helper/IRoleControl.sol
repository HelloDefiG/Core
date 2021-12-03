// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IOwnable.sol";

interface IRoleControl is IOwnable {
    function roleApprove(
        string memory role,
        address to,
        bool _allow
    ) external;

    function getRoleApproved(string memory role, address to)
        external
        view
        returns (bool);
}
