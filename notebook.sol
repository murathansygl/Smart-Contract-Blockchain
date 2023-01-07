// SPDX-License-Intentifier: MIT
pragma solidity ^0.8.7;


//constructor function is called only once.


// constant vars. cost less gas

contract ForAndWhileLoops {
    function loops() external pure {
        for (uint i=0; i<10; i++) {
            //code
            if (i == 3) {
                continue;   //continue looping
            }
            if (i == 5) {
                break;  //exits loop
            }
        }

        uint j = 0;
        while (j < 10) {
            j++;
        }
    }

    

    function sum(uint _n) external pure returns (uint) {
//  function function_name(input_type input_name) returns(return_type) {}
    uint s;
    for (uint i = 1; i <= _n; i++) {
        s += i;
    } 
    return s;
    }

    //bigger #loops = more gas
}

contract Mapping {
//like a dict in Python
//for efficient lookup
//store data in key:value pairs (not iterable)
//key data is not stored in a mapping, only its keccak256 hash is used to look up the value.

//KeyType can be any built-in value type, bytes, string, or any contract 
    //or enum type. Other user-defined or complex types, such as mappings, 
    //structs or array types are not allowed. ValueType can be any type, 
    //including mappings, arrays and structs.
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => bool)) public isFriend;

    function examples() external {
        balances[msg.sender] = 123;
        uint bal = balances[msg.sender];
        uint bal2 = balances[address(2)]; //0

        balances[msg.sender] += 546; //123 + 456 = 579

        delete balances[msg.sender];

        isFriend[msg.sender][address(this)] = true;
    }
}

contract IterableMapping {
    mapping(address => uint) public balances;
    mapping(address => bool) public inserted;
    address[] public keys;  //creates an array of addresses named 'keys'

    function set (address _key, uint _val) external {
        balances[_key] = _val;

        if (!inserted[_key]) {
            inserted[_key] = true;
            keys.push(_key);
        }
     }

    function getSize() external view returns (uint) {
        return keys.length;
    }

    //now that we know the size of an array, we can create a for loop

    function first() external view returns (uint) {
        return balances[keys[0]];
    }

    function last() external view returns (uint) {
    return balances[keys[keys.length-1]];
    }

    function get(uint _i) external view returns (uint) {
        return balances[keys[_i]];
    }


}

contract Structs {
    //allow you to group data

    //Structs can be declared outside of a contract and imported into 
    //another contract. Generally, it is used to represent a record. 
    //To define a structure struct keyword is used, which creates a new data type.
    struct Car {
        string model;
        uint year;
        address owner;
    }

    //structs can be used for many purposes
    Car public car;
    Car[] public cars;
    mapping(address => Car[]) public carsByOwner;

    function examples() external {
        Car memory toyota = Car("Toyota",1990,msg.sender);  //initialize a struct
        Car memory lambo = Car({model:"Lamborghini", year:1990, owner:msg.sender}); //another way of initialization
        Car memory tesla; //another way of initialization
        tesla.model = "Tesla";
        tesla.year = 2010;
        tesla.owner = msg.sender;
        
        //we initialized these inside the memory. after the function is finished executing, these structs will be gone
        //put these in a state variable, 

        cars.push(toyota);
        cars.push(lambo);
        cars.push(tesla);

        //but this can be done in a single line
        cars.push(Car("Ferrari", 2020, msg.sender));

        //Car memory _car = cars[0];

        //to be able to change this value, replace the keyword 'memory' with 'storage'
        //memory means that keep the var in memory, and delete once finished.
        //changes are not kept

        //_car.model;
        //_car.year;
        //_car.owner;

        Car storage _car = cars[0];
        _car.year = 1999;
        delete _car.owner; //deletes the owner of this car
        delete cars[1]; //this will delete the whole instance


    }


}

contract FunctionModifier {

    //can be used to change the behaviour of functions in a declarative way.
    bool public paused;
    uint public count;

    function setPause (bool _paused) external {
        paused = _paused;
    }

    modifier whenNotPaused() {
        require(!paused, "paused");
        _; //call the actual function that this modifier wraps
    }

    function inc () external whenNotPaused {
        // require(!paused, "paused");    --no need anymore, modifier already handles
        count += 1;
    }

    function dec () external whenNotPaused {
        // require(!paused, "paused");    --no need anymore, modifier already handles
        count -= 1;
    }

    //modifiers can also take input

    modifier cap (uint _x) {
        require (_x < 100, "x > 100");
        _;
    }
    function incBy(uint _x) external whenNotPaused cap(_x) { //takes in two modifiers
        
        count += _x;
    }

    //sandwich modifier

    modifier sandwich() {
        //code here
        count += 10;  //first this is run
        _;

        //more code here
        count *= 2;  //third this
    }

    function foo() external sandwich { //initially modifier runs
        count += 1;  //second this
    }


//Modifiers can be used to:
    //Restrict access
    //Validate inputs
    //Guard against reentrancy hack



//Some common modifiers
    //External - Functions that will be called by outside contracts. 
            //These functions can not be called internally.
    //Internal - Functions that are only accessed only within the contract 
            //in which it is declared or any connected contracts.
    //Public - Functions and variables that can be called both internally 
            //and externally by outside contracts.
    //Private - Functions and variables that can only be called in the 
            //contract in which it is declared. These functions cannot be 
            //called by connected contracts either.
}


contract Event {
    //to write data on blockchain, but it is not stored
    //Events allow us to log any actions in our smart contract related 
        //to the Ethereum blockchain. These events can be listened to and 
        //can be used to update a user interface or trigger some external 
        //functionality. They can also be used to return the value of a certain 
        //transaction which can be useful for a smart contract that reads 
        //those values to perform an operation.

    event Log(string message, uint val);
    event IndexedLog(address indexed sender, uint val);
    //up to 3 params can be indexed, allows you to search by the variable indexed

    function example() external {   //This is not a read-only function but a transactional function
        emit Log("foo", 1234);
        emit  IndexedLog(msg.sender, 789);
    }

    event Message(address indexed _from, address indexed _to, string message);

    function sendMessage(address _to, string calldata message) external {
        emit Message(msg.sender, _to, message);
    } //calldata is because string is a dynamic type ???

    //this is basically a chat app where you need to pay for every messages.
    //enables you to send messages to a user
}

contract Error {
    //Three ways to throw an error: require, revert, assert
    //gas refunded, state updates are reverted
    //custom errors save gas

    function testRequire(uint _i) public pure {
        require (_i <= 10, "i > 10"); //if not satisfied returns the given string
    }

    //can also be done with 'revert'
    function testRevert(uint _i) public pure {
        if (_i > 10) {
            revert ("i > 10");   //better option when used with if statements
        }
        
    }


    //assert checks for a condition that should always be true.
    uint public num = 123;

    function testAssert() public view {
        assert (num == 123);
    }

    error MyError(address caller, uint i);

    function testCustomError (uint _i) public view {        //
        //require(_i <= 10, "very long error message costs more gas");
        revert MyError(msg.sender, _i);
        //code 
    }

}

//LIBRARIES
//you cannot decclare state vars inside libraries
//Similar to contracts but differs in that it cannot receive ether and hold a state variable.
//It’s similar to embedded functions in contracts.
library Math {
    function max(uint x, uint y) internal  pure returns (uint) {
        return x >= y ? x : y;
    }
    //making it external is illogical since the rest of the contract will use this
    // making it private is also illogical since it is not only used by the library itself
    // if you make it public, you need to store it separately
}

contract Test {
    function testMax (uint x, uint y) public returns (uint){
        return Math.max(x,y);
    }
}

//libraries with state vars

library ArrayLib {
    function find(uint[] storage arr, uint x) internal view returns (uint)  {  //read from state vars --> cannot be pure, has to be view
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == x) {
                return i;
            }
            revert ("not found");
        }

    }
}
contract TestArray {
    uint[] public arr = [3,2,1];

    function testFind() external view returns (uint i) {
        return ArrayLib.find(arr, 2);

    }
}


//IF YOU USE A DYNAMIC DATATYPE AS A VARIABLE, YOU NEED TO DECLARE ITS DATA LOCATION

//storage   --> a var is a state var
//memory    --> data is loaded into memory
//calldata  --> light memory, used for function inputs

contract DataLocations {
    struct MyStruct {
        uint foo;
        string text;
    }

    mapping(address => MyStruct) public myStructs;

    function examples() external {
        myStructs[msg.sender] = MyStruct({foo:123, text:"bar"});

        MyStruct storage myStruct = myStructs[msg.sender];
        //declare struct as storage when you want to modify the struct
        myStruct.text = "foo";

        //if you just want to read w/o modification, declare it as memory
        MyStruct memory readOnly = myStructs[msg.sender];
        //you cannot perform any change in this variable

        //Note that arrays initialized in memory cannoy possess a dynamic size
        uint[] memory memArr = new uint[](3);
    }

    //calldata is like memory except that it can be used for function input
    //why? since it can save gas
    //calldata vars are not modifiable
    //
}

//INHERITENCE

contract A {
    function foo() public pure virtual returns (string memory) {
        //The keyword 'virtual' tells that the function can be inherited and customized by a child contract
        return "A";
    }

    function bar() public pure virtual returns (string memory) {
        return "A";
    }

    function baz() public pure returns (string memory) {
        return "A";
    }

    //more code here
}

contract B is A { //is A forms the linkage
    function foo() public pure override returns (string memory) {
        //override tells that the function comes from contract A
        return "B";
    }

    function bar() public pure virtual override returns (string memory) {
        return "B";
    }
}

contract C is B { //is A forms the linkage

    function bar() public pure override returns (string memory) {
        //comes from A to B and from there to C
        return "C";
    }
}


//INTERFACE
//allow contracts (for example, token contracts) that have different working logic 
//but do the same job to have a common standard, so that someone who wants to work 
//with these contracts writes a single code according to this standard instead of 
//writing code specific to each contract.

//call another contract without its code

//Cannot have any functions implemented
//Can inherit from other interfaces
//Declared functions must be external
//Cannot declare state variables
//Cannot declare a constructor
//Standards such as ERC20, ERC721, ERC1155 are actually defined as an interface.

interface ICounter { //interfaca naming convention = "I" + contract_name
    function count() external view returns (uint);
    function inc() external;


}

contract CallInterface {
    uint public count;
    function examples(address _counter) external {
        ICounter(_counter).inc();
        count = ICounter(_counter).count();
    }
}

//CALL FUNCTION 
//To interact with functions of other contracts, call function is used. 

//This is the recommended method to use when you're just sending Ether 
//via calling the fallback function. However, it is not the recommended 
//way to call existing functions.

contract TestCall {
    string public message;
    uint public x;

    event Log(string message);

    fallback() external payable {
        emit Log("fallback was called");
    //fallback function is executed when a function called does not exist in this contract
    //if fallback did not exist, the calling would fail.
    }

    function foo(string memory _message, uint _x) external payable returns (bool, uint) {
        message = _message;

        x = _x;

        return (true, 999);
    }
}

contract Call {
    bytes public data;
    //payable enables sending ETH
    function callFoo(address _test) external payable {  //the dict inside call specifies the ETH and gas amount in wei
        (bool success, bytes memory _data) = _test.call{value: 111}(abi.encodeWithSignature(   //value: 111,gas:5000 was the original input. gas removed since it is a restriction that errors the function calling
        //while calling this function, 111 wei was paid
            "foo(string,uint256)","call foo", 123   //the final two are the inputs
            ));  //within the first "" do not put any space, and specify the type of uint
        require (success, "call failed");
        data = _data;
    }

    function callDoesNotExist (address _test) external {
        (bool success, ) = _test.call(abi.encodeWithSignature("doesNotExist()"));
        require(success, "call failed");
    }
}

//When a contract inherits from a parent contract, how to call the constructor of the parent?

contract S {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract T {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}

//if you know the parameters to pass
contract U is S("s"), T("t") {
    
}

//if you do not know and want to make it dynamic
contract V is S, T {
    constructor(string memory _name, string memory _text) S(_name) T(_text) {
        
    }

}

//another way (combination of both)
contract W is S("s"), T {
    constructor(string memory _text) T(_text) {
       
        }
}

//The order of execution (comes from contract W is S, T)
// 1.S
// 2.T
// 3.W
//(not from the line starts with constructor)

/* CALLING A PARENT FUNCTION: DIRECT VS SUPER
    E
   / \ 
  F   G
   \ /
    H
*/

contract E {
    event Log(string message);

    function foo() public virtual {
        emit Log("E.foo");
    }

    function bar() public virtual {
        emit Log("E.bar");
    }
}


contract F is E {
    
    function foo() public virtual override {
        emit Log("F.foo");
        E.foo();
    }

    function bar() public virtual override {
        emit Log("F.bar");
        super.bar();    //same as calling E.bar() BUT.... only so far
    }
}

contract G is E {
  

    function foo() public virtual override {
        emit Log("G.foo");
        E.foo();
    }

    function bar() public virtual override {
        emit Log("G.bar");
        super.bar();
    }
}

contract H is F, G {


    function foo() public override(F,G) {
        F.foo();
    }

    function bar() public override(F,G) {
        super.bar();        //Now, super calls all parents F,G, and they call E
    }
}

//CALLING OTHER CONTRACTS
/*
contract CallTestContract {
    function setX(TestContract _callee, uint _x) public {
        uint x = _callee.setX(_x);
    }

    function setXFromAddress(address _addr, uint _x) public {
        TestContract callee = TestContract(_addr);
        callee.setX(_x);
    }

    function setXandSendEther(TestContract _callee, uint _x) public payable {
        (uint x, uint value) = _callee.setXandSendEther{value: msg.value}(_x);
    }
}

contract TestContract {
    uint public x;
    uint public value;

    function setX(uint _x) public returns (uint) {
        x = _x;
        return x;
    }

    function setXandSendEther(uint _x) public payable returns (uint, uint) {
        x = _x;
        value = msg.value;

        return (x, value);
    }
}
*/

contract CallTestContract {
    /*
    function setX(address _test, uint _x) external {
        TestContract(_test).setX(_x);  //one way of calling is initialization
    }
    */
    function setX(TestContract _test, uint _x) external {
        _test.setX(_x); //now there is not need to initialize it, it is given as input
    }

    function getX(address _test) external view returns (uint x) {
        x = TestContract(_test).getX();  //one way of calling is initialization
    }

    function setXandSendEther(address _test, uint _x) external payable returns (uint, uint) {
        TestContract(_test).setXandReceiveEther{value: msg.value}(_x); 
        require(msg.value >= _x,"you need to pay more");
    }

    function getXandValue(address _test) external view returns (uint, uint) {
        (uint x, uint value) = TestContract(_test).getXandValue();
        return (x,value);
    }
}




contract TestContract {
    uint public x;
    uint public value = 123;

    function setX(uint _x) external {
        x=_x;
    }

    function getX() external view returns (uint) {
        return x;
    }

    function setXandReceiveEther (uint _x) external payable { //payable means that you can send ETH to this function
        x = _x;
        value = msg.value;
    }

    function getXandValue() external view returns (uint, uint) {
        return (x,value);

    }
    
}

//SENDING ETH
/* There are three ways to send ETH

- transfer  -> 2300 gas limit, reverts if fails
- send      -> 2300 gas limit, returns bool showing its success
- call      -> all gas, returns bool and data

*/

contract SendEther{
    //to make this contract able to receive ETH is to make its constructor payable
    constructor() payable {

    }
    //or create a payable fallback function
    fallback() external payable {
        
    }

    //OR, just create a receive() function to make the contract receive ETH
    receive() external payable {}

    function sendViaTransfer(address payable _to) external payable {
        //hardcoded to prevent reentrancy attack
        _to.transfer(123); //amount of ETH to send AND it sends only 2300 gas
    }

    function sendViaSend(address payable _to) external payable {
        //almost never used in real life, either transfer or call is used
        bool sent = _to.send(123); //amount of ETH to send AND it sends only 2300 gas
        require(sent, "send failed");
    }

    function sendViaCall(address payable _to) external payable {
        //the recommended way to send ETH
        //beware reentrancy attack
        (bool success, bytes memory data) = _to.call{value:123}("");
        require(success,"call failed");
    }
} 

contract EthReceiver {
    event Log(uint amount, uint gas);

    receive() external payable {
        emit Log(msg.value, gasleft());
    }
}


//VERIFY SIGNATURE
/* Steps to verify signature
0. message to sign
1. hash(message)
2. sign(hash(message), signature) | offchain
3. ecrecover(hash(message), signature) == signer
*/

contract VerifySig {
    //the ecrecover function is expected to return _signer (address of the signer)
    function verify (address _signer, string memory _message, bytes memory _sig) external pure returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message: \n32",_messageHash));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v){
        require(_sig.length == 65, "invalid signature length"); //32 + 32 + 1 = 65

        //now we need r, s, and v
        //every dynamic data type, the first 32 bytes stores the length of the data
        //_sig is not the actual signature, it is the pointer to its location in memory
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

    }
}