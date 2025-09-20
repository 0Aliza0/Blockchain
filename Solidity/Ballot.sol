// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Ballot{
    //Entities :
    uint startTime;
    uint currentTime;

    enum State{
        Reg, //0
        Vote, //1
        Count, //2
        End //3
    }
    State state;
    struct Proposal{
        string name;
        uint8 voteCount;
    }

    Proposal[] public proposalList;

    struct Voter{
        uint8 vote;
        uint8 weight;
        bool voted;
    }

    mapping (address => Voter) public voterList;
    address public chairPerson;

    constructor(uint8 proposalCount){
        chairPerson = msg.sender;
        // weight = 0 ثبت نام نکرده
        // weight > 0 ثبت نام کرده
        voterList[chairPerson].weight = 2;
        for(uint i=0;i < proposalCount;i++){
            proposalList.push(Proposal ({name:"" , voteCount:0}));
        }
    }
    //Functions :
    // Call only by chairPerson
    modifier checkOverflow1(address voterAdr) {

        require(msg.sender == chairPerson , "Only chairPerson can call Register Others!");
        require(voterAdr != chairPerson , "chairPerson can't Register Again!");
        require(voterList[voterAdr].voted == false , "Voter Already Voted!");
        _;
    }
    function register(address voterAdr) public checkState(State.Reg) checkOverflow1(voterAdr){

        voterList[voterAdr].weight = 1;
    }
    // Call by chairPerson and other voters
     modifier checkOverflow2(uint8 proposalId) {

        require(proposalId >= 0 && proposalId < proposalList.length , "Invalid proposalID");
        require(voterList[msg.sender].weight > 0 , "You don't Registered Yet!");
        require(voterList[msg.sender].voted == false , "Voter Already Voted");
        _;
    }
    function vote(uint8 proposalId) public checkState(State.Vote) checkOverflow2(proposalId){ 

        voterList[msg.sender].vote = proposalId;
        voterList[msg.sender].voted = true;

        proposalList[proposalId].voteCount += voterList[msg.sender].weight;
    }
    // choose winner :
    
    function count() public checkState(State.Count) returns(uint winnerPropId , uint8 winnerPropVoteCount){

        uint proposalCount = proposalList.length;
        for(uint8 i=0; i < proposalCount ;i++){
            if(proposalList[i].voteCount > winnerPropVoteCount){
                winnerPropVoteCount = proposalList[i].voteCount;
                winnerPropId = i;
            }
        }
    //We insert proposals with the same votes that meet the winning conditions into a separate array.
    uint8[] memory winPropList = new uint8[] (proposalCount);
    uint8 j = 0;
    for(uint8 i=0; i < proposalCount ;i++){
        if(proposalList[i].voteCount == winnerPropVoteCount){
            winPropList[j] = i;
            j++;
        }
    }
    winnerPropId = winPropList[getRand(j)];

    return (winnerPropId, winnerPropVoteCount);
    }
    function getRand(uint max) public view returns(uint){
            
        return uint8(uint256( keccak256(abi.encodePacked(block.prevrandao, block.timestamp) ) ) )% max;
        
    }
    // State Transition :
    modifier checkState(State st){
        updateState();
        require(state != State.End , "Voting Finished!");
        require(state == st , "Improper State!");
        _;
    }

    function start() public{
        require(msg.sender == chairPerson , "Only chairPerson can call start!");
        startTime = block.timestamp;
        currentTime = block.timestamp;
        state = State.Reg;
    }
    function updateState() private{
        currentTime = block.timestamp;
        if(currentTime <= (startTime + 1 minutes))
        state = State.Reg;
        else if(currentTime <= (startTime + 2 minutes))
        state = State.Vote;
         else if(currentTime <= (startTime + 3 minutes))
        state = State.Count;
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
        else if(state == State.Count)
        stateStr = "Count";
        else
        stateStr = "End";
        return stateStr;
    }

}
