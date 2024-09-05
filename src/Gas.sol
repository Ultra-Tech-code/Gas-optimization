// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 

import "./Ownable.sol";

contract GasContract is Ownable {
    uint256 public totalSupply; // cannot be updated
    uint256 public paymentCounter;
    mapping(address => uint256) public balances;
    uint256 private constant TRADE_PERCENT = 1;
    address public contractOwner;
    mapping(address => uint256) public whitelist; // NEED
    address[5] public administrators; // NEED 
    
    struct ImportantStruct {
        uint256 amount;
    }
    mapping(address => ImportantStruct) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        if (!checkForAdmin(msg.sender)) {
            revert();
        }
        _;
    }

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        string recipient
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < administrators.length; ii++) {
            administrators[ii] = _admins[ii];
            balances[contractOwner] = totalSupply;
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
        
        whitelist[_userAddrs] = _tier;
        whitelist[_userAddrs] = 3;
        
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {
        whiteListStruct[msg.sender] = ImportantStruct(_amount);
    
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[_recipient] -= whitelist[msg.sender];
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (true, whiteListStruct[sender].amount);
    }
}