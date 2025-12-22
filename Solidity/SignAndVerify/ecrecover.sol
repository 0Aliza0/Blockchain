// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract VerifySignature{

    function getMessageHash(string memory _msg) public pure returns(bytes32 hash){
        hash = keccak256(abi.encodePacked(_msg));
    }
    //signature will be diffrent for diffrent accounts.
    function getEthSignedHash(bytes32 hash) public pure returns(bytes32 ethSignedHash){
        ethSignedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    function verify(address _claimedSigner, string memory _msg, bytes memory signature) public pure returns(bool){
        
        bytes32 msgHash = getMessageHash(_msg);
        bytes32 ethSignedHash = getEthSignedHash(msgHash);
        return recoverSigner(ethSignedHash , signature) == _claimedSigner;
    }
    //recognize real recovered signer
    function recoverSigner(bytes32 _ethSignedHash , bytes memory _signature) public pure returns(address recoveredSigner){
        //ECDSA
        //65 bytes
        //r: first 32bytes , after the length prefix
        //S: second 32bytes
        //v: final byte(first byte of the next 32 bytes)
        (bytes32 r,bytes32 s,uint8 v) = splitSignature(_signature);
        recoveredSigner = ecrecover(_ethSignedHash, v , r ,s);
    }
    function splitSignature(bytes memory sig) public pure returns(bytes32 r , bytes32 s , uint8 v){

        require(sig.length == 65 , "invalid signature length");
        assembly{
            
            r:= mload(add(sig,32))
            s:= mload(add(sig,64))
            v:= byte(0,mload(add(sig,96)))
        }
    }
}