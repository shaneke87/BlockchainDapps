// https://api.nasa.gov/neo/rest/v1/feed?start_date=START_DATE&end_date=END_DATE&api_key=API_KEY
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;

contract Oracle {

    // Diracion del owner
    address owner;

    // Numero de asteroides
    uint public numberAsteroids;

    //Evento que recibe datos del oraculo
    event __callbackNewData();

    // Constuctor
    constructor() public {
        owner = msg.sender;
    }

    // Restriccion de la ejecucion de las funciones
    modifier onlyOwner() {
        require(owner == msg.sender, "Only Owner");
        _;
    }

    // Recibe datos del oraculo
    function update() public onlyOwner {
        emit __callbackNewData();
    }

    // Funcion para configuracion manual del umero de asteroides
    function setNumberAsteroids(uint _num) public onlyOwner {
        numberAsteroids = _num;
    }
}