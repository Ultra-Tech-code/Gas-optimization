// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 

import "./Ownable.sol";

contract GasContract is Ownable {
    uint256 public constant totalSupply = 1000000000; // cannot be updated
    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist; // NEED
    address[5] public administrators; // NEED 
    mapping(address => uint256) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    modifier onlyAdminOrOwner() {
        if (!checkForAdmin(msg.sender)) {
            revert();
        }
        _;
    }

    constructor(address[] memory _admins, uint256 _totalSupply) {
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            administrators[ii] = _admins[ii];
            balances[msg.sender] = _totalSupply;
        }
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        bool admin = false;
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                admin = true;
            }
        }
        return admin;
    }

    function balanceOf(address _user) public view returns (uint256 balance) {
        balance = balances[_user];
    }
    
    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        public
        onlyAdminOrOwner
    {
        if (_tier >= 255) {
            revert();
        }
        
        whitelist[_userAddrs] = 3;
        
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {
        whiteListStruct[msg.sender] = _amount;
    
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[_recipient] -= whitelist[msg.sender];
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (true, whiteListStruct[sender]);
    }
}