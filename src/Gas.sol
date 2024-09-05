// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.26; 

contract GasContract {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;
    address[5] public administrators;
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
        balances[msg.sender] = _totalSupply;
        for (uint256 i; i < 5; ++i) {
            administrators[i] = _admins[i];
        }
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

    function getPaymentStatus(address sender) external view returns (bool status, uint256 value) {
        (status, value) = (true, whiteListStruct[sender]);
    }

    function checkForAdmin(address _user) public view returns (bool isAdmin) {
        for (uint256 i; i < 5; ++i) {
            if (administrators[i] == _user) {
                isAdmin = true;
            }
        }
    }

    function balanceOf(address _user) public view returns (uint256 balance) {
        balance = balances[_user];
    }
}