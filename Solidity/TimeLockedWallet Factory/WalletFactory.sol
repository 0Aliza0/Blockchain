// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "./TimeLockedWallet.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/IERC20.sol";

contract WalletFactory{

    address owner;
    //userAddress => wallets
    mapping(address => address[]) wallets;
    event Created(address wallet, address from , address to , uint creatAt , uint unlockDuration , uint amount);

    //prevents accidental sending of ether to the factory
    receive() external payable{
        revert();
    }
    modifier onlyOwner{
        require(msg.sender == owner,"Only Owner can call this!");
        _;
    }
    function getWallets(address _user) public view returns(address[] memory){
        return wallets[_user];
    }
    function newTimeLockedWallet(address owner_,uint unlockDuration_, address tokenAdr) public payable returns(address wallet){

        //create new wallet
        TimeLockedWallet tlw = new TimeLockedWallet(address(this), owner_, unlockDuration_);
        wallet = address(tlw);
        //Add wallet to owner's wallets
        wallets[owner_].push(wallet);
        // send Ether from this tranaction to the created contract.
        payable(wallet).transfer(msg.value);
        //send 1000 tokens from this transaction to the created contract.
        IERC20 token = IERC20(tokenAdr);
        token.transfer(wallet , 1000*1e18);
        emit Created(wallet, msg.sender , owner_ , block.timestamp , unlockDuration_ , msg.value);
    }
}