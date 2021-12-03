// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract LaunchLock {
    using SafeMath for uint256;

    mapping (address=>launcher) launchers;
    mapping (address=>bool) launching;

    struct launcher{
        address account;
        uint256 total;
        uint256 cliff;
        uint256 during;
        uint256 overTime;
        uint256 initTime;
    }

    function _lockAmount(
        address account,
        uint256 total,
        uint256 cliff,
        uint256 during
    ) internal {
        require(
            !launching[account],
            "LaunchLock: The address has be launched."
        );
        launchers[account] = launcher(
            account,
            total,
            cliff.mul(86400),
            during,
            cliff.add(during).mul(86400),
            block.timestamp
        );
        launching[account] = true;
    }

    function lockOf(address owner) public view returns(uint256){
        if(!launching[owner]){
            return 0;
        }
        uint256 timestamp = block.timestamp;
        uint256 diff;
        unchecked {
            diff = timestamp - launchers[owner].initTime;
        }
        if(diff >= launchers[owner].overTime){
            return 0;
        }
        if(diff <= launchers[owner].cliff){
            return launchers[owner].total;
        }
        unchecked {
            diff -= launchers[owner].cliff;
        }
        uint256 day = diff.div(86400);
        uint256 lock = launchers[owner].during.sub(day);
        return launchers[owner].total.mul(lock).div(launchers[owner].during);
    }
}
