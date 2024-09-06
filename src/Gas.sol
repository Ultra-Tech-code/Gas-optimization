// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 



contract GasContract {

    uint256 public totalSupply; // cannot be updated
    uint256 public paymentCounter;
    uint256 wasLastOdd = 1;
    address public contractOwner;
    address[5] public administrators;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public whiteListTransfers;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public isOddWhitelistUser;
    mapping(address => bool) public adminisCheck;


    modifier onlyAdminOrOwner() {
        require(checkForAdmin(msg.sender));
        _;
    }

    modifier checkIfWhiteListed() {
        require(whitelist[msg.sender] > 0);
        _;
    }

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
    

        for(uint i; i < _admins.length; i++) {
            adminisCheck[_admins[i]] = true;
            administrators[i] = _admins[i];
        }
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        return adminisCheck[_user];
    }

    function balanceOf(address _user) public view returns (uint256 balance) {
        return balances[_user];
    }

    function transfer( address _recipient, uint256 _amount, string calldata _name) public returns (bool status_) {
        require(balances[msg.sender] >= _amount);
        // require(bytes(_name).length < 9);

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
       
        return true;
    }


    function addToWhitelist(address _userAddrs, uint256 _tier) public onlyAdminOrOwner{
        require(_tier < 255 );

            if (_tier > 3) {
                whitelist[_userAddrs]  = 3;
            } else if (_tier == 1) {
                whitelist[_userAddrs]  = 1;
            } else if (_tier > 0) {
                whitelist[_userAddrs]  = 2;
            }
            wasLastOdd = 1 - wasLastOdd;
            isOddWhitelistUser[_userAddrs] = 1 - wasLastOdd;
            
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public checkIfWhiteListed() {
        require(_amount > 3);
        
        whiteListTransfers[msg.sender] = _amount;
        require(balances[msg.sender] >= _amount);

        uint256 whiteListedAmount = whitelist[msg.sender];

        balances[msg.sender] -= _amount - whiteListedAmount;
        balances[_recipient] += _amount - whiteListedAmount;
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (whiteListTransfers[sender] != 0, whiteListTransfers[sender]);
    }


}
