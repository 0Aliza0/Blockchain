// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";
contract TimeLock is Ownable{
    constructor(address initialOwner) Ownable(initialOwner){}
    uint public immutable lockDuration = 1 weeks;
    //amount of etheryou deposited is saved in balance
    mapping(address => uint) public balances;
    //when you can withdraw is saved in lockTime
    mapping(address => uint) public lockTime;

    function deposit() public payable{
        //update balance
        balances[msg.sender] += msg.value;
        //update locktime 1 week from now
        lockTime[msg.sender] = block.timestamp + lockDuration;
    }
    function withdraw() public{
        //check that the sender has ether deposited in this contract in the mapping and the balance is > 0
        require(balances[msg.sender] > 0 , "Insufficient Funds!");
        //check that the now time is > the time saved in the lock time mapping
        require(block.timestamp > lockTime[msg.sender] , "Lock Time Has Not Expired!");
        //update the balance
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        //send the ether back to the sender
        (bool result, ) = msg.sender.call{value: amount}("");
        require(result , "Failed To Send Ether");
    }
    function increaseTimeLock(address _account , uint _seconds) public onlyOwner{
        lockTime[_account] += _seconds;
    }
    function decreaseTimeLock(address _account , uint _seconds) public onlyOwner{
        lockTime[_account] -= _seconds;
    }
}