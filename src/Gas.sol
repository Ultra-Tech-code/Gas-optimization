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

    modifier onlyAdminOrOwner() {
        if (msg.sender == contractOwner) {
            _;
        } else {
            revert(
                "Error in Gas contract - onlyAdminOrOwner modifier : revert happened because the originator of the transaction was not the admin, and furthermore he wasn't the owner of the contract, so he cannot run this function"
            );
        }
    }

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

    function checkForAdmin(address _user) public view returns (bool admin_) {

        return (administrators[0] == _user ||
            administrators[1] == _user ||
            administrators[2] == _user ||
            administrators[3] == _user ||
            administrators[4] == _user);
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool status_) {
        require(
            balances[msg.sender] >= _amount,
            "Gas Contract - Transfer function - Sender has insufficient Balance"
        );
        require(
            bytes(_name).length < 9,
            "Gas Contract - Transfer function -  The recipient name is too long, there is a max length of 8 characters"
        );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;

        return true;
    }

    function addToWhitelist(
        address _userAddrs,
        uint256 _tier
    ) public onlyAdminOrOwner {
        require(
            _tier < 255,
            "Gas Contract - addToWhitelist function -  tier level should not be greater than 255"
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
        address senderOfTx = msg.sender;
        whiteListStruct[senderOfTx] = _amount;
        uint256 whitelistSenderTx = whitelist[senderOfTx];

        balances[senderOfTx] -= _amount - whitelistSenderTx;
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
