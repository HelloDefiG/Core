// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./helper/ILaunchBase.sol";

contract DFG is ERC20, Ownable {
    using SafeMath for uint256;
    uint256 public constant total = 1000000000 * 1e18;

    bool public isInit = false;

    constructor() ERC20("Defig", "DFG") Ownable() {}

    function initSupply(
        address _ecosystemFund,
        address _playtoEarn,
        address _nftMining,
        address _marketing,
        address _team,
        address _advisor,
        address _strategy,
        address _public
    ) external onlyOwner {
        require(!isInit, "DFG: inited");
        require(
            _ecosystemFund != address(0),
            "DFG: The '_ecosystemFund' is a zero address"
        );
        require(
            _playtoEarn != address(0),
            "DFG: The '_playtoEarn' is a zero address"
        );
        require(
            _nftMining != address(0),
            "DFG: The '_nftMining' is a zero address"
        );
        require(
            _marketing != address(0),
            "DFG: The '_marketing' is a zero address"
        );
        require(
            _team != address(0),
            "DFG: The '_team' is a zero address"
        );
        require(
            _advisor != address(0),
            "DFG: The '_advisor' is a zero address"
        );
        require(
            _strategy != address(0),
            "DFG: The '_strategy' is a zero address"
        );
        require(
            _public != address(0),
            "DFG: The '_public' is a zero address"
        );
        isInit = true;
        uint256 _supply = total.mul(20).div(100);
        _mint(_ecosystemFund, _supply);
        ILaunchBase(_ecosystemFund).init(_supply);

        _supply = total.mul(10).div(100);
        _mint(_playtoEarn, _supply);
        ILaunchBase(_playtoEarn).init(_supply);

        _supply = total.mul(10).div(100);
        _mint(_nftMining, _supply);
        ILaunchBase(_nftMining).init(_supply);

        _supply = total.mul(18).div(100);
        _mint(_marketing, _supply);
        ILaunchBase(_marketing).init(_supply);

        _supply = total.mul(15).div(100);
        _mint(_team, _supply);
        ILaunchBase(_team).init(_supply);
        
        _supply = total.mul(2).div(100);
        _mint(_advisor, _supply);
        ILaunchBase(_advisor).init(_supply);
        
        _supply = total.mul(20).div(100);
        _mint(_strategy, _supply);
        ILaunchBase(_strategy).init(_supply);
        
        _supply = total.mul(5).div(100);
        _mint(_public, _supply);
        ILaunchBase(_public).init(_supply);
    }
}
