// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract GasContract is Ownable {
    address[5] public administrators;
    mapping(address => bool) public adminsMapping;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public whiteListTransfers;
    uint256 public totalSupply;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    modifier onlyAdmin() {
        if (checkForAdmin(msg.sender)) {
            _;
        } else {
            revert();
        }
    }

    modifier checkIfWhiteListed() {
        require(whitelist[msg.sender] > 0 && whitelist[msg.sender] < 4);
        _;
    }

    constructor(address[] memory _admins, uint256 _totalSupply) {
        totalSupply = _totalSupply;

        for (uint256 i; i < administrators.length; i++) {
            if (_admins[i] != address(0)) {
                administrators[i] = _admins[i];
                adminsMapping[_admins[i]] = true;
                uint256 balance = _admins[i] == msg.sender ? _totalSupply : 0;
                balances[_admins[i]] = balance;
            }
        }
    }

    function addToWhitelist(
        address _userAddrs,
        uint256 _tier
    ) public onlyAdmin {
        require(_tier < 255 && _tier > 0);
        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier;
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        return adminsMapping[_user];
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public {
        require(balances[msg.sender] >= _amount);
        require(bytes(_name).length < 9);
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public checkIfWhiteListed {
        whiteListTransfers[msg.sender] = _amount;
        require(balances[msg.sender] >= _amount);
        require(_amount > 3);
        uint256 _tier = whitelist[msg.sender];
        balances[msg.sender] = balances[msg.sender] - _amount + _tier;
        balances[_recipient] = balances[_recipient] + _amount - _tier;

        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(
        address sender
    ) public view returns (bool, uint256) {
        return (whiteListTransfers[sender] != 0, whiteListTransfers[sender]);
    }
}
