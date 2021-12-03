// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library PRNG {
    function random(uint256 seed) internal view returns (uint16) {
        uint16 randomNumber = uint16(
            uint256(keccak256(abi.encodePacked(block.timestamp, seed))) % 10000
        );
        return randomNumber;
    }

    function probability(uint256 seed, uint16 expectation)
        internal
        view
        returns (bool)
    {
        uint16 rd = random(seed);
        if (rd <= expectation) {
            return true;
        }
        return false;
    }
}
