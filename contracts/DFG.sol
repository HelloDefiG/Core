// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./helper/LaunchLock.sol";

contract DFG is ERC20, Ownable, LaunchLock {
    using SafeMath for uint256;
    uint256 public constant total = 1000000000 * 1e18;
    uint256 public maxTxAmount = 5000000 * 1e18;
    uint256 public maxBalance = 10000000 * 1e18;

    bool public isInit = false;

    uint256 public _maxAdvisor = 0;
    uint256 public _totalAdvisor =0;
    uint256 public _maxStrategy = 0;
    uint256 public _totalStrategy =0;


    mapping (address=>bool) private _whiteAddress;

    constructor() ERC20("DefiG Token", "DFG") Ownable() {
        setWhite(_msgSender(), true);
        setWhite(address(0), true);
    }

    function setWhite(address owner, bool isWhite) public onlyOwner{
        _whiteAddress[owner] = isWhite;
    }

    function whiteOf(address owner) public view returns(bool){
        return _whiteAddress[owner];
    }

    function launchAdvisor(address recipient, uint256 amount) external onlyOwner{
        require(
            amount >= 1 * 1e18,
            "DFG: Launch amount must be or more than 1 DFG."
        );
        require(
            recipient != address(0),
            "DFG: 'recipient' is zero address."
        );
        require(
            _totalAdvisor.add(amount) <= _maxAdvisor,
            "DFG: _totalAdvisor exceeds _maxAdvisor"
        );
        setWhite(recipient, true);
        _totalAdvisor += amount;
        _lockAmount(recipient, amount, 360, 720);
        _mint(recipient, amount);
        setWhite(recipient, false);
    }

    function launchStrategy(address recipient, uint256 amount) external onlyOwner{
        require(
            amount >= 1 * 1e18,
            "DFG: Launch amount must be or more than 1 DFG."
        );
        require(
            recipient != address(0),
            "DFG: 'recipient' is zero address."
        );
        require(
            _totalStrategy.add(amount) <= _maxStrategy,
            "DFG: _totalStrategy exceeds _maxStrategy"
        );
        setWhite(recipient, true);
        _totalStrategy += amount;
        uint256 lock = amount.mul(80).div(100);
        _lockAmount(recipient, lock, 0, 360);
        _mint(recipient, amount);
        setWhite(recipient, false);
    }

    function initSupply(
        address _ecosystemFund,
        address _playtoEarn,
        address _nftMining,
        address _marketing,
        address _team,
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
            _public != address(0),
            "DFG: The '_public' is a zero address"
        );
        isInit = true;
        uint256 _supply = total.mul(20).div(100);
        uint256 lock = _supply.mul(80).div(100);
        setWhite(_ecosystemFund, true);
        _mint(_ecosystemFund, _supply);
        _lockAmount(_ecosystemFund, lock, 0, 1080);
        

        _supply = total.mul(10).div(100);
        setWhite(_playtoEarn, true);
        _mint(_playtoEarn, _supply);
        
        
        _supply = total.mul(10).div(100);
        setWhite(_nftMining, true);
        _mint(_nftMining, _supply);

        _supply = total.mul(18).div(100);
        lock = _supply.mul(80).div(100);
        setWhite(_marketing, true);
        _mint(_marketing, _supply);
        _lockAmount(_marketing, lock, 0, 360);

        _supply = total.mul(15).div(100);
        setWhite(_team, true);
        _mint(_team, _supply);
        _lockAmount(_team, _supply, 360, 1080);
        
        _supply = total.mul(2).div(100);
        _maxAdvisor = _supply;
        
        _supply = total.mul(20).div(100);
        _maxStrategy = _supply;
        
        _supply = total.mul(5).div(100);
        setWhite(_public, true);
        _mint(_public, _supply);
    }

    function _beforeTokenTransfer(
        address from,
        address ,
        uint256 amount
    ) internal virtual override {
        uint256 lock = lockOf(from);
        if(lock > 0){
            require(
                amount.add(lock) <= balanceOf(from),
                "DFG: balance is locking."
            );
        }
        if(!whiteOf(from)){
            require(
                amount <= maxTxAmount,
                "DFG: Transfer amount exceeds the maxTxAmount."
            );
        }
    }

    function _afterTokenTransfer(
        address ,
        address to,
        uint256 
    ) internal virtual override {
        if(!whiteOf(to)){
            require(
                balanceOf(to) <= maxBalance,
                "DFG: Balance of target address exceeds the maxBalance."
            );
        }
    }
}
