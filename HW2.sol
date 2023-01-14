pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

contract FeeCollector {
    address public owner; //public address of the owner
    uint256 public balance; //balance on the smart contract
    
    constructor() {
        owner = msg.sender; // address of deployer
    }
    
    receive() payable external {
        balance += msg.value; // add or reduce balance in wei (1 ETH = 1,000,000,000,000,000,000 Wei)
    }
    
    
    function withdraw(uint amount, address payable destAddr) public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(amount <= balance, "Insufficient funds");
        
        destAddr.transfer(amount); // send funds to given address
        balance -= amount;
    }
}