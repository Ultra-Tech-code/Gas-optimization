// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
contract GasContract{
    address[5] public administrators;
    uint256 wasLastOdd = 1;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public isOddWhitelistUser;
    mapping(address => uint) public whiteListStruct;
    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdmin() {
        if (checkForAdmin(msg.sender)) {
            _;
        }  else {
            revert();
        }
    }

    modifier checkIfWhiteListed() {
        uint256 usersTier = whitelist[msg.sender];
        require(
            usersTier > 0
        );
        require(
            usersTier < 4
        );
        _;
    }

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {

        for (uint256 ii = 0; ii < 5; ii++) {
            if (_admins[ii] != address(0)) {
                administrators[ii] = _admins[ii];
                if (_admins[ii] == msg.sender) {
                    balances[msg.sender] = _totalSupply;
                    emit supplyChanged(_admins[ii], _totalSupply);
                } else {
                    emit supplyChanged(_admins[ii], 0);
                }
            }
        }
    }

    function checkForAdmin(address _user) public view returns (bool) {
        for (uint256 i = 0; i <5; i++) {
            if (administrators[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool) {
        require(
            balances[msg.sender] >= _amount
        );
        require(
            bytes(_name).length < 9
        );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);   
        return true;
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        public
        onlyAdmin
    {
        require(
            _tier < 255
        );
        if (_tier > 3) {
            whitelist[_userAddrs] = 3;
        } 
        else if (_tier == 1) {
            whitelist[_userAddrs] = 1;
        } 
        else if (_tier > 0 && _tier < 3) {
            whitelist[_userAddrs] = 2;
        }
        else{
        whitelist[_userAddrs] = _tier;
        }
        isOddWhitelistUser[_userAddrs] = wasLastOdd;
        wasLastOdd = 1 - wasLastOdd;
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public checkIfWhiteListed() {
        whiteListStruct[msg.sender] = _amount;
        
        require(
            balances[msg.sender] >= _amount
        );
        require(
            _amount > 3
        );
        balances[msg.sender] -= _amount - whitelist[msg.sender];
        balances[_recipient] += _amount - whitelist[msg.sender];
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (whiteListStruct[sender]!=0, whiteListStruct[sender]);
    }

}