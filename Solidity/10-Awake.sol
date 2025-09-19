// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Awake{

    address public owner;
    uint public immutable tourCost = 1e18; 

    struct Member{ //enum
        bool isMember;
        bool isAwake;
        bool isCancel;
        bool isPaid;
    }
    mapping(address => Member) memberList;

    uint memberCount;
    uint awakeCount;
    uint share;

    constructor(){
        owner = msg.sender;
    }
    //Functions :
    function register() public payable{

        //TODO : check the state of contract
        require(memberList[msg.sender].isMember == false , "Already Registered!");
        require(msg.value == tourCost , "Value Not Equal 1Eth!");

        memberList[msg.sender].isMember = true;
        memberCount++;
    }
    function awake() public{

        require(memberList[msg.sender].isMember , "You Don't Registered!");
        
        memberList[msg.sender].isAwake = true;
        awakeCount++;
    }
    function cancel() public{

        require(memberList[msg.sender].isMember , "You Don't Registered!");

        if(memberList[msg.sender].isAwake){
            memberList[msg.sender].isAwake = false;
            awakeCount--;
        }
        memberList[msg.sender].isCancel = true;
        require(memberList[msg.sender].isPaid == false , "You Are Already Paid!");

        paySend(msg.sender , tourCost);
        memberList[msg.sender].isPaid = true;
    }
        function payShare() public{

        require(memberList[msg.sender].isMember , "You Don't Registered!");
        require(memberList[msg.sender].isAwake , "You Don't Awake!");
        require(memberList[msg.sender].isCancel == false , "You Already cancel!");
        require(memberList[msg.sender].isPaid == false , "You Are Already Paid!");

        share = getBalanceContract() / awakeCount;
        paySend(msg.sender , share);

        memberList[msg.sender].isPaid = true;
        }
        // Pay & Balance functions :
        function paySend(address to , uint amount) public{
            
            require(address(this).balance >= amount , "Not Enough Balance!");
            bool result = payable (to).send(amount);

            require(result == true , "Failure in Payment Via Send!");
        }
        function getBalanceContract() public view returns(uint){

            return address(this).balance; //wei
        }
        function getBalanceAccount(address adr) public view returns(uint){
            
            return adr.balance; //wei
        }
}