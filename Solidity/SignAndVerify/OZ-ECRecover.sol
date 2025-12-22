// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract VerifySignatureOZ{

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    using SignatureChecker for address; //for V2

    function getMessageHash(string memory _msg) public pure returns(bytes32 hash){
        
        hash = keccak256(abi.encodePacked(_msg));
    }
    //verify that the message was signed by the (private keys of) claimedSigner
    function ECDSAVerify(bytes32 hash, address claimedSigner, bytes memory signature) public pure returns(bool){

        return hash.toEthSignedMessageHash().recover(signature) == claimedSigner;
    }
    function ECDSAVerifyV2(bytes32 hash, address claimedSigner, bytes memory signature) public view returns(bool){

        return claimedSigner.isValidSignatureNow(hash.toEthSignedMessageHash(),signature);
    }
}