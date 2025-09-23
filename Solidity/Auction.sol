// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;
contract Auction{
    address public owner;
    address public beneficiary;

    uint public auctionStartTime;
    uint public auctionEndTime;

    uint public highestBid;
    address public highestBider;
    bool ended;

    mapping(address => uint) pendingRefunds;

    struct Bid{
        address bider;
        uint bidPrice;
    }
    Bid[] internal bids;

    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner{
        require(msg.sender == owner , "Only Owner Can Call!");
        _;
    }
    //Functions :
    function startAuction(address _beneficiary , uint _basePrice , uint _deadLineDur) public onlyOwner{

        beneficiary = _beneficiary;

        highestBid = _basePrice;
        highestBider = _beneficiary;

        auctionStartTime = block.timestamp;
        auctionEndTime = auctionStartTime + _deadLineDur;
    }
    modifier isValidTime{
        require(block.timestamp < auctionEndTime , "Auction Ended!");
        _;
    }
    modifier isHighestBid{
        require(msg.value > highestBid , "Value Is Less Than HighestBid!");
        _;
    }
    function bid() public payable isValidTime isHighestBid{
        
        if(highestBider != beneficiary)
        pendingRefunds[highestBider] += highestBid;

        //update highest bid
        highestBid = msg.value;
        highestBider = msg.sender;

        bids.push(Bid(highestBider,highestBid));
    }
    function refund() public returns(bool){

        require(ended == true , "Auction Doesn't Ended!");

        uint amount = pendingRefunds[msg.sender];

        require(amount > 0 , "Your Refund Is Zero!");
        bool result = paySend(msg.sender , amount);
        
        if(result){
        pendingRefunds[msg.sender] = 0;
        return true;
        }else{
            return false;
        }
    }
    function payBeneficiary() public onlyOwner returns(bool){

        require(ended == true , "Auction Doesn't Ended!");

        bool result = paySend(beneficiary , highestBid);
        return result;
    }
    function endAuction() public onlyOwner{
        
        require(block.timestamp >= auctionEndTime , "Auction Can't End At This Time!");
        ended = true;
    }
    function getBids() public view returns(Bid[] memory){

        return bids;
    }
    function getWinner() public view returns(address , uint){
        return (highestBider , highestBid);
    }

    function paySend(address to, uint amount) public returns(bool){

        require(address(this).balance >= amount , "Not Enough Balance!");

        bool result = payable(to).send(amount);
        return result;
    }
    // 300 seconds --> 5 min & 1000000000000000000 wei --> 1 ETH

}
