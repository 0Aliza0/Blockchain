// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract MultiSigWallet{

    event Deposit(address indexed sender,uint amount,uint balance);
    event SubmitTransaction(address indexed owner,uint indexed txIndex,address indexed to,uint value,bytes data);
    event ConfirmTransaction(address indexed owner,uint indexed txIndex);
    event RevokeTransaction(address indexed owner,uint indexed txIndex);
    event ExecuteTransaction(address indexed owner,uint indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationRequired;

    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }
    Transaction[] transactions;

    //txIndex => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    modifier txExist(uint txIndex_){
        require(txIndex_ < transactions.length, "tx does not Exist!");
        _;
    }
    modifier notConfirmed(uint txIndex_){
        require(!isConfirmed[txIndex_][msg.sender], "tx already confirmed by you!");
        _;
    }
    modifier notExecuted(uint txIndex_){
        require(!transactions[txIndex_].executed, "tx already executed!");
        _;
    }
    modifier onlyOwner(){
        require(isOwner[msg.sender], "not owner!");
        _;
    }

    constructor(uint numConfirmationRequired_) payable{

        //for test
        address[3] memory _owners = [
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
            0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
            0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
        ];
        require(_owners.length > 0,"owners required!");
        require(numConfirmationRequired_ > 0 && numConfirmationRequired_ <= _owners.length,"invalid number of required confirmations!");

        for(uint i;i < _owners.length;i++){

            address owner = _owners[i];
            require(owner != address(0),"invalid owner!");
            require(!isOwner[owner],"owner not unique!");
            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationRequired = numConfirmationRequired_;
    }
    receive() external payable{
        emit Deposit(msg.sender,msg.value,address(this).balance);
    }
    //Txs should be submit by one of registered owners.
    function submitTransaction(address _to,uint _value,bytes memory _data) public onlyOwner{
        uint txIndex = transactions.length;
        transactions.push(
            Transaction({
            to:_to,
            value:_value,
            data:_data,
            executed:false,
            numConfirmations:0
        })
        );
        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint _txIndex) public onlyOwner txExist(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex){

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender,_txIndex);
    }

    function revokeTransaction(uint _txIndex) public onlyOwner txExist(_txIndex) notExecuted(_txIndex){

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;
        emit RevokeTransaction(msg.sender,_txIndex);
    }
    function executeTransaction(uint _txIndex) public onlyOwner txExist(_txIndex) notExecuted(_txIndex) returns(bool success){

        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmations >= numConfirmationRequired,"cant execute tx!");
        transaction.executed = true;
        (success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success,"tx execution failed!");
        emit ExecuteTransaction(msg.sender,_txIndex);
    }
    function batchExecute() public onlyOwner{

        for(uint i;i < transactions.length;i++){
            if(!transactions[i].executed)
            executeTransaction(i);
        }
    }
    function getOwner() public view returns(address[] memory){
        return owners;
    }
    function getTxCount() public view returns(uint){
        return transactions.length;
    }
    function getTx(uint _txIndex) public view returns(
        address to,
        uint value,
        bytes memory data,
        bool executed,
        uint numConfirmations
    ){
        Transaction storage transaction = transactions[_txIndex];
        return(
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}
//My Test Contract ----------->
contract Target{

    event Received(address sender, uint amount);
    uint public i;
    function callMe(uint j) public payable{
        i += j;
        emit Received(msg.sender,msg.value);
    }
    function getData() public pure returns(bytes memory){
        return abi.encodeWithSignature("callMe(uint256)", 10);
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}
