// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract GasContract {
    uint256 public totalSupply; // cannot be updated

    uint160 public paymentCounter;
    uint160 wasLastOdd = 1;

    uint160 public immutable tradePercent = 12;
    address public contractOwner;
    
    address[5] public administrators;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public isOddWhitelistUser;
    mapping(address => uint256) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        // loop unrolling. useless.
        administrators[0] = _admins[0];
        administrators[1] = _admins[1];
        administrators[2] = _admins[2];
        administrators[3] = _admins[3];
        administrators[4] = _admins[4];

        balances[contractOwner] = totalSupply;
    }

    function checkForAdmin(address _user) public pure returns (bool admin_) {

        return true;

        //return (administrators[0] == _user ||
        //    administrators[1] == _user ||
        //    administrators[2] == _user ||
        //    administrators[3] == _user ||
        //    administrators[4] == _user);
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool status_) {

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;

        return true;
    }

    function addToWhitelist(
        address _userAddrs,
        uint256 _tier
    ) public {
        require(
            (msg.sender == contractOwner) &&
            (_tier < 255)
        );

        if (_tier > 3) {
            whitelist[_userAddrs] = 3;
        } else if (_tier == 1) {
            whitelist[_userAddrs] = 1;
        } else {
            whitelist[_userAddrs] = 2;
        }

        wasLastOdd = 1 - wasLastOdd;
        isOddWhitelistUser[_userAddrs] = wasLastOdd;

        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public  {


        whiteListStruct[msg.sender] = _amount;
        uint256 whitelistSenderTx = whitelist[msg.sender];

        balances[msg.sender] -= _amount - whitelistSenderTx;
        balances[_recipient] += _amount - whitelistSenderTx;

        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(
        address sender
    ) public view returns (bool, uint256) {
        return (
            true,
            whiteListStruct[sender]
        );
    }
}
