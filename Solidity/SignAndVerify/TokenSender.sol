// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import "./MyToken.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/IERC20.sol";


contract TokenSender{

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    mapping(bytes32 => bool) executed;

    function getHash(address from , uint amount, address to, address token, uint nonce) public pure returns(bytes32 hash){

        hash = keccak256(abi.encodePacked(from, amount, to, token, nonce));
    }
    function transfer(address from , uint amount, address to, address token, uint nonce, bytes memory signature) public {

        //calculate the hash of all the requisite values
        bytes32 hash = getHash(from, amount, to, token, nonce);
        //convert it to a signed message hash
        bytes32 ethSignedHash = hash.toEthSignedMessageHash();

        //require that this signature hasn't already executed
        require(!executed[ethSignedHash], "Already executed!");
        //make sure signer is the person on whose behalf we're executing the transaction
        require(ethSignedHash.recover(signature) == from, "signature does not come from sender");
        //mark this signature as having been executed now
        executed[ethSignedHash] = true;
        
        //Transfer tokens from sender(signer) to recipient
        bool success = IERC20(token).transferFrom(from, to, amount);
        require(success,"Transfer Failed!");
    }
}