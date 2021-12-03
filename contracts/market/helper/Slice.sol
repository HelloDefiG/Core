// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Slice {
    function uint256Array(uint256[] memory arr, uint256 start, uint256 size) internal pure returns(uint256[] memory){
        uint256 len = arr.length;
        if(start >= len){
            return new uint256[](0);
        }
        uint256 count = len - start;
        if(count > size){
            count = size;
        }
        uint256[] memory result = new uint256[](count);
        for(uint256 i = 0; i < count; i++){
            result[i] = arr[i+start];
        }
        return result;
    }
}
