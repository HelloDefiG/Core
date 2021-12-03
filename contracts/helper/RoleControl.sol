// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

abstract contract RoleControl is Ownable {
    mapping(string => mapping(address => bool)) private _roleApprovals;

    event RoleApproval(
        string indexed role,
        address indexed approved,
        bool approval
    );

    constructor() {}

    function roleApprove(
        string memory role,
        address to,
        bool _allow
    ) public onlyOwner {
        _roleApprove(role, to, _allow);
    }

    function getRoleApproved(string memory role, address to)
        public
        view
        returns (bool)
    {
        return _roleApprovals[role][to];
    }
    
    function _roleApprove(
        string memory role,
        address to,
        bool _allow
    ) private {
        _roleApprovals[role][to] = _allow;
        emit RoleApproval(role, to, _allow);
    }
}
