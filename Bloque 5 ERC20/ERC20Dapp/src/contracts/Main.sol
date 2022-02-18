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

    // Establecer el precio de un token
    function PercioTokens(uint _numTokens) internal pure returns (uint256) {
        //Conversion de tokens a ethers: 1 token -> 1 ether
        return _numTokens*(1 ether);
    }

    // Compramos tokens mediante direccion de destino y cantidad de tokens a comprar
    function send_tokens(address _destinatario, uint256 _numTokens) public payable {
        // se requiere que la cantidad de tokens a transferir no sea mayor a 10
        require(_numTokens <= 10, "La cantidad de tokens es demasiado alta");
        // Estabecer el precio de los tokens
        uint256 coste = PercioTokens(_numTokens);
        // Se evalua la cantodad de ethers paga el cliente
        require(msg.value >= coste, "Compra menos tokens o paga con mas ethers");
        // <diferencia de lo que el cliente paga
        uint256 returnValue = msg.value - coste;
        // Retorna la cantidad de tokens deterinada
        msg.sender.transfer(returnValue);
        // Obtener el balance de tokens disponibles
        uint256 Balance = balance_total();
        // Se requiere que los tokens que se vayan a comprar esten disponibles en el contrato
        require(_numTokens <= Balance, "Compra un numero menor de tokens");
        // Se genera la transferencia desde el contrato del ERC20
        token.transfer(_destinatario, _numTokens);
    }

    // Generacion de tokens al contrato
    function GeneraTokens(uint256 _numTokens) public onlyByOwner() {
        // Llamamos la funcion del contrato ERC20 para incrementar la cantidad de tokens del contrato
        token.increaseTotalSupply(_numTokens);
    }

    // Modificador que permite la ejecucion solo por el owner
    modifier onlyByOwner() {
        // se requiere que el dueño seq quein ejecute la fucncion
        require(msg.sender == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    // >Obtenermos el balance de tokens de una direcccion especificada por parametro
    function balance_direccion( address _direccion) public view returns(uint256) {
        // regresamos la cantidad de tokens de una direccion con el metodo del contrato ERC20
        return token.balanceOf(_direccion);
    }

    // Obtenemos el balance de tokens total del smart contract
    function balance_total() public view returns(uint256) {
        // regresamos el total de los tokens del smartcontract con la funcion totalSupply del contrato ERC20
        return token.balanceOf(contrato);
    }

    


}