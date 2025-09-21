// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Awake{

    uint startTime;
    uint currentTime;

    enum State{
        Reg,
        Vote,
        Pay,
        End
    }
    State state;

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
    // Modifiers :
    modifier checkNotRegister(){
        require(memberList[msg.sender].isMember == false , "Already Registered!");
        _;
    }
    modifier checkPayValue(){
        require(msg.value == tourCost , "Value Not Equal 1Eth!");
        _;
    }
    modifier checkRegister(){
        require(memberList[msg.sender].isMember , "You Don't Registered!");
        _;
    }
    modifier checkPaid(){
        require(memberList[msg.sender].isPaid == false , "You Are Already Paid!");
        _;
    }
    modifier checkAwake(){
        require(memberList[msg.sender].isAwake , "You Don't Awake!");
        _;
    }
    modifier checkCancel(){
        require(memberList[msg.sender].isCancel == false , "You Already cancel!");
        _;
    }
    //Functions :
    function register() public checkState(State.Reg) checkNotRegister() checkPayValue() payable{

        //TODO : check the state of contract
        memberList[msg.sender].isMember = true;
        memberCount++;
    }
    function awake() public checkState(State.Vote) checkRegister(){
        
        memberList[msg.sender].isAwake = true;
        awakeCount++;
    }
    function cancel() public checkState(State.Vote) checkRegister() checkPaid(){

        if(memberList[msg.sender].isAwake){
            memberList[msg.sender].isAwake = false;
            awakeCount--;
        }
        memberList[msg.sender].isCancel = true;

        paySend(msg.sender , tourCost);
        memberList[msg.sender].isPaid = true;
    }
        function payShare() public checkState(State.Pay) checkRegister() checkAwake() checkCancel() checkPaid(){

        if(share == 0)
        share = getBalanceContract() / awakeCount;
        else
        share = getBalanceContract();

        paySend(msg.sender , share);

        memberList[msg.sender].isPaid = true;
        }
        // Pay & Balance functions :
        function paySend(address to , uint amount) public{

            bool result = payable (to).send(amount);
            require(result == true , "Failure in Payment Via Send!");
            require(address(this).balance >= amount , "Not Enough Balance!");
        }
        function getBalanceContract() public view returns(uint){

            return address(this).balance; //wei
        }
        function getBalanceAccount(address adr) public view returns(uint){
            
            return adr.balance; //wei
        }
        //State Transition :
        modifier checkState(State st){

            updateState();
            require(state != State.End , "Voting Finished!");
            require(state == st , "Improper State!");
        _;
    }
        function start() public{
            require(msg.sender == owner , "Only owner Can Call!");
            startTime = block.timestamp;
            currentTime = block.timestamp;
            state = State.Reg;
        }
        function updateState() private {

            currentTime = block.timestamp;
            if(currentTime <= (startTime + 1 minutes))
            state = State.Reg;
            else if(currentTime <= (startTime + 2 minutes))
            state = State.Vote;
            else if(currentTime <= (startTime + 3 minutes))
            state = State.Pay;
            else
            state = State.End;
        }
        function getState() public returns(string memory){

            updateState();
            string memory stateStr;
            if(state == State.Reg)
              stateStr = "Reg";
            else if(state == State.Vote)
              stateStr = "Vote";
            else if(state == State.Pay)
            stateStr = "Pay";
            else
               stateStr = "End";
            return stateStr;
        }
}