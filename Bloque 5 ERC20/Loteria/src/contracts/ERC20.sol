// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.4 <0.7.0;
//pragma experimental ABIEncoderV2;
import "./SafeMath.sol";


// Interface para declarar los metodos que se consumiran desde el exterior
interface IERC20 {
    // Devuelve la cantidad de tokens en existencia
    function totalSupply() external view returns(uint256);
    // Devuelve la cantidad de tokens para ua direccion indicada por parametro
    function balanceOf(address account) external view returns (uint256);
    // devuelve el numero de tokens que puede gastar la persona aprovada por el propietario
    function allowance(address owner, address spender) external view returns(uint256);
    // Devuelve un valor booleano resultado de la operacion de transferencia
    function transfer(address recipient, uint256 amount) external returns(bool);
    // Devuelve un valor booleano resultado de la operacion de transferencia de la loteria
    function transfencia_loteria(address emiter, address recipient, uint256 amount) external returns(bool);
    // Devuelve un valor booleano con el resultado de la operacion de gasto
    function approval(address spender, uint256 amount) external returns(bool);
    // Devuelve un valor booleano con el resultado de la operacion de paso de una cantidad de tokens usuando el metodo allowance()
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    //Evento qe se debe de emitir cuando una cantidad de tokens pasa de un origen a in destino
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Evento que se debe emitir cuando se establece ua asignacion con el metodo allowance
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

//Contrato que implementa la interface IERC20
contract ERC20Basic is IERC20 {

    // Nombre de el token ERC20
    string public constant name = "ERC20DApp";
    // Symbolo del token ERC20
    string public constant symbol = "EDAPP";
    // Desimales de el token ERC20
    uint8 public constant decimals = 2;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);

    // se usaa para mantener seguras las operaciones que se realicen en el smart contract
    using SafeMath for uint256;

    // mapping que relaciona una direccion con la cantidad de tokens que que dueño
    mapping (address => uint256) balances;
    // mapping de una direccion que distrubuye una cantidad de tokens sobre otras direcciones
    mapping(address => mapping(address => uint256)) allowed;
    // variable que nos permite guardar el total de los tokens que hay creados
    uint256 totalSupply_;

    //constructor donde indicamos el total de de tokens con el que inicia el smart contract
    constructor(uint256 initialSupply) public {
        // pasamos la cantidad de monedas pasadas por parametro a la variable totalSupply_
        totalSupply_ = initialSupply;
        // añadimos el total de tokens a la cuenta que despliega el contrato
        balances[msg.sender] = totalSupply_;
    }

    // implemantamos la funcion de la interfaz
    function totalSupply() public override view returns(uint256){
        // retornamos la cantidad total de tokens en existencia
        return totalSupply_;
    }

    // Funcion que permite incrementar el numero de tokens totales segun el cantidad pasada por parametro
    function increaseTotalSupply(uint256 newTokensAmount) public {
        //incrementamos el numero de tokens de la variable totalSupply_
        totalSupply_ += newTokensAmount;
        // incrementamos los tokens de la direccion que solicito el incremento de tokens
        balances[msg.sender] += newTokensAmount;
    }
    
    // implemantamos la funcion de la interfaz
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        //regresamos con el mapping la cantidad de tokens que posee la direcion pasada por parametro
        return balances[tokenOwner];
    }

    // implemantamos la funcion de la interfaz
    function allowance(address owner, address delegate) public override view returns(uint256) {
        // validamos si de la direccion del dueño se pude gastar a su nombre con la direccion del delegado y en que cantidad
        return allowed[owner][delegate];
    }

    // implemantamos la funcion de la interfaz
    function transfer(address recipient, uint256 numTokens) public override returns(bool) {
        // se requiere que el numero de tokens a transferir sea menor o igual al de la persona que los va a transerir
        require(numTokens <= balances[msg.sender], "ERC20: Compra mas tokens o Transfiere menos");
        // restamos las monedas transferidas de la persona que transfiere
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        // se pasan los tokens a la direccion que recibe la transferencia
        balances[recipient] = balances[recipient].add(numTokens);
        // emitimos el evento de la transferencia efectuada
        emit Transfer(msg.sender, recipient, numTokens);
        // regresamos true en cso de que la transferencia se halla efectuado de forma correcta
        return true;
    }

    // implemantamos la funcion de la interfaz
    function transfencia_loteria(address _emisor, address recipient, uint256 numTokens) public override returns(bool) {
        // se requiere que el numero de tokens a transferir sea menor o igual al de la persona que los va a transerir
        require(numTokens <= balances[_emisor], "ERC20: Compra mas tokens o Transfiere menos");
        // restamos las monedas transferidas de la persona que transfiere
        balances[_emisor] = balances[_emisor].sub(numTokens);
        // se pasan los tokens a la direccion que recibe la transferencia
        balances[recipient] = balances[recipient].add(numTokens);
        // emitimos el evento de la transferencia efectuada
        emit Transfer(_emisor, recipient, numTokens);
        // regresamos true en cso de que la transferencia se halla efectuado de forma correcta
        return true;
    }


    // implemantamos la funcion de la interfaz
    function approval(address delegate, uint256 numTokens) public override returns(bool){
        // se requiere que la direccion delegate no sea la misma del dueño de los tokens
        require(msg.sender != delegate, "ERC20: No se Puede delegar tokens a la misma direccion del dueño");
        // ingresamos al mapping la persona delegada y la cantdad de tokens delegados
        allowed[msg.sender][delegate] = numTokens;
        // emitimos el evento de delegacion Approval
        emit Approval(msg.sender, delegate, numTokens);
        //regresamos si fue correcta la delegacion
        return true;
    }

    // implemantamos la funcion de la interfaz
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool) {
        // se requeire que el dueño cuente con la cantidad a transferir
        require(numTokens <= balances[owner], "ERC20: No cuentas con los tokens a tranferir");
        // se requiere que el delegado cuente con la cantidad de tokens a tranferir
        require(numTokens <= allowed[owner][msg.sender], "ERC20: El dueño no cuenta con esta cantidad o el delegado no tiene permitido transferir esta canidad");
        // retiramos la cantdad de tokens al dueño
        balances[owner] = balances[owner].sub(numTokens);
        // retiramos los tokens delegados a la direccion delegada
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        // enviamos la cantidad de tokens a el comprador
        balances[buyer] = balances[buyer].add(numTokens);
        // Emitimos el evento de de transferencia
        emit Transfer(owner, buyer, numTokens);
        // regresamos true si la transferencia fue un exito
        return true;
    }
}