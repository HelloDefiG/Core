// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../IDFG.sol";

abstract contract LaunchBase {
    using SafeMath for uint256;

    address private _owner;

    uint256 public total;
    uint256 public launched;

    uint256 private _initTime;

    uint256 private _cliff;
    uint256 private _initial;
    uint256 private _overTime;
    uint256 private _prevTime;

    address private _account;
    address private _dfgAddress;

    event Launch(address indexed account, uint256 amount);

    constructor(
        address account,
        address dfgAddress,
        uint256 cliff,
        uint256 overTime,
        uint256 initial
    ) {
        _account = account;
        _dfgAddress = dfgAddress;
        _cliff = cliff * 24 * 60 * 60;
        _overTime = overTime;
        _initial = initial;

        _owner = msg.sender;
    }

    function init(uint256 _total) public {
        require(
            msg.sender == _dfgAddress,
            "Launch: caller must be DFG contract"
        );
        total = _total;
        _initTime = block.timestamp;
    }

    function interval() public view returns (uint256) {
        require(_initTime > 0, "Launch: Not init");
        if (_prevTime == 0) {
            return (block.timestamp - _initTime).div(86400);
        }
        return (block.timestamp - _prevTime).div(86400);
    }

    function launch() public {
        require(_owner == msg.sender, "Launch: launch caller must be owner");
        require(_initTime > 0, "Launch: Not init");
        require(
            block.timestamp > (_initTime + _cliff),
            "Launch: Lock up period not expired"
        );
        require(launched < total, "Launch: Launch over");
        uint256 amount = _launchOf();
        require(amount > 0, "Launch: Launch amount is zero");
        if (amount + launched > total) {
            unchecked {
                amount = total - launched;
            }
            launched = total;
        } else {
            launched += amount;
        }

        IDFG(_dfgAddress).transfer(_account, amount);
        emit Launch(_account, amount);
    }

    function _launchOf() private returns (uint256) {
        uint256 timestamp = block.timestamp;
        uint256 amount;
        uint256 during;
        uint256 day;
        if (_prevTime == 0) {
            if (_initial > 0) {
                amount += total.mul(_initial).div(100);
            }
            unchecked {
                during = timestamp - _initTime - _cliff;
            }
            day = during.div(86400);
            if (day > 0) {
                amount += total.mul(day).div(_overTime);
            }
            _prevTime = _initTime + _cliff + day.mul(86400);
        } else {
            unchecked {
                during = timestamp - _prevTime;
            }
            day = during.div(86400);
            if (day > 0) {
                amount = total.mul(day).div(_overTime);
                _prevTime += day.mul(86400);
            }
        }
        return amount;
    }
}
