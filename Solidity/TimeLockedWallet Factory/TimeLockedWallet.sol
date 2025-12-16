// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/IERC20.sol";

contract TimeLockedWallet{

    address public architect;
    address public owner;
    uint public createdAt;
    uint public unlockDate;

    event Received(address from, uint amount);
    event Withdraw(address to , uint amount);
    event WithdrawTokens(address tokenAdr, address to , uint amount);

    constructor(address architect_, address owner_ , uint unlockDuration_){

        architect = architect_;
        owner = owner_;
        createdAt = block.timestamp;
        unlockDate = createdAt + unlockDuration_;
    }

    modifier onlyOwner{
        require(msg.sender == owner,"Only Owner can call this!");
        _;
    }
    //keep all the ether sent to this address
    receive() external payable{
        emit Received(msg.sender , msg.value);
    }
    //only owner can withdraw ethers after specified time
    function withdrawEthers() public onlyOwner{
        //send all the balance
        payable(msg.sender).transfer(address(this).balance);
        emit Withdraw(msg.sender , address(this).balance);
    }

    function withdrawTokens(address _tokenAdr) public onlyOwner{
        //send all the token balance
        IERC20 token = IERC20(_tokenAdr);
        uint tokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender , tokenBalance);
        emit WithdrawTokens(_tokenAdr , msg.sender , tokenBalance);
    }

    function info() public view returns(address,address,uint,uint,uint){
        
        return(architect,owner,createdAt,unlockDate,address(this).balance);
    }
}