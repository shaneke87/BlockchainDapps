// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.4 <0.7.0;
//pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract main {
    // Instanciamos el contrato ERC20
    ERC20Basic private token;

    // Dueño del contrato
    address public owner;

    // Direccion del Smartcontract
    address public contrato;

    // Contructor
    constructor() public {
        // Se crean los tokens que se utilizaran en la app se pueden incrementar con el metodo increaseSupply()
        token = new ERC20Basic(10000);
        // pasamos a la variable owner la direccion del dueño del contrato
        owner = msg.sender;
        // pasamos a la variable contrato la direccion del contrato inteligente
        contrato = address(this);
    }

    //Obtenemos la direccion del dueño del contrato
    function getOwner() public view returns(address){
        return owner;
    }

    //Obtenemos la direccion del Smart Contract
    function getContract() public view returns(address) {
        return contrato;
    }

    // Compramos tokens mediante direccion de destino y cantidad de tokens a comprar
    function send_tokens(address _destinatario, uint256 _numTokens) public {
        // Se genera la transferencia desde el contrato del ERC20
        token.transfer(_destinatario, _numTokens);
    }

    // >Obtenermos el balance de tokens de una direcccion especificada por parametro
    function balance_direccion( address _direccion) public view returns(uint256) {
        // regresamos la cantidad de tokens de una direccion con el metodo del contrato ERC20
        return token.balanceOf(_direccion);
    }

    // Obtenemos el balance de tokens total del smart contract
    function balance_total() public view returns(uint256) {
        // regresamos el total de los tokens del smartcontract con la funcion totalSupply del contrato ERC20
        return token.totalSupply();
    }

    


}