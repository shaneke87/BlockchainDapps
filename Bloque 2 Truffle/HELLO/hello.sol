// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.0;
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;

contract hello {
    string public message = "Hola Mundo";

    function getMessage() public view returns(string memory) {
        return message;
    }

    //Envio de u mensaje a la blockchain
    function setMessage(string memory _message) public {
        message = _message;
    }
}