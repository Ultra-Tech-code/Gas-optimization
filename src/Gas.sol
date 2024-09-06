// SPDX-License-Identifier: MIT

pragma solidity 0.8.26; 

contract GasContract {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) private whiteListStruct;
    address[5] public administrators;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory admins, uint256 totalSupply) {
        balances[msg.sender] = totalSupply;
        for (uint256 i; i < 5; ) {
            administrators[i] = admins[i];
            unchecked {
                ++i;
            }
        }
    }

    function transfer(address to, uint256 amount, string calldata name) external {
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    function addToWhitelist(address user, uint256 tier) external {
        if (!checkForAdmin(msg.sender)) {
            revert();
        }

        if (tier >= 255) {
            revert();
        }
        
        whitelist[user] = 3;
        
        emit AddedToWhitelist(user, tier);
    }

    function whiteTransfer(address to, uint256 amount) external {
        whiteListStruct[msg.sender] = amount;
        balances[msg.sender] -= amount;
        balances[to] += amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[to] -= whitelist[msg.sender];
        
        emit WhiteListTransfer(to);
    }

    function checkForAdmin(address user) public view returns (bool isAdmin) {
        for (uint256 i; i < 5; ) {
            if (administrators[i] == user) {
                isAdmin = true;
            }
            unchecked {
                ++i;
            }
        }
    }

    function getPaymentStatus(address sender) external view returns (bool status, uint256 value) {
        (status, value) = (true, whiteListStruct[sender]);
    }

    function balanceOf(address user) external view returns (uint256 balance) {
        balance = balances[user];
    }
}