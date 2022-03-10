// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Loteria {
    //Instancia del contrato token
    ERC20Basic private token;

    //Direcciones del owner y del contrato inteligente
    address public owner;
    address public contrato;

    // numero de tokens a crear
    uint public tokens_creados = 10000;

    // Eventos
    event ComprandoTokens(uint, address);

    // COntructor del contrato
    constructor() public {
        //Se asigna una cantidad de tokens al desplegarse el contrato
        token = new ERC20Basic(tokens_creados);
        // se asigna la direccion dde qeuin despliega el contrato como dueño del mismo
        owner = msg.sender;
        // se asigna la direccion del contrato inteligente
        contrato = address(this);
    }

    // --------- TOKEN ---------- //

    //Establecer el Precio del token
    function PrecioTokens(uint _numTokens) internal pure returns(uint) {
        //se retorna el precio del token que sera 1 token -> 1 ether
        return _numTokens*(1 ether);
    }

    //Gererar mas tokens para la loteria
    function GenerarTokens(uint _numTokens) public Unicamente(msg.sender) {
        // se generar los tokens con la funcion del contrato ERC20
        token.increaseTotalSupply(_numTokens);
    }

    // Modifier para que solo el propietario del contrato pueda ejecutar funciones
    modifier Unicamente(address _direccion) {
        //se requiere que la direccion sea la misma que la del propietario del contrato
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }
    
    // Comprar Tokens para comperar boletos / tickets para la loteria
    function CompraTokens(uint _numTokens) public payable {
        // Calcular el coste de los tokens
        uint coste = PrecioTokens(_numTokens);
        // Se requiere que el valor de ethers pagados sea qeuivalente al coste
        require(msg.value >= coste, "Compra menos tokens o paga con mas ethers");
        //Direfencia a pagar en caso de que tenga mas ether
        uint returnValue = msg.value - coste;
        // Transferencia de la diferencia
        msg.sender.transfer(returnValue);
        //Obtener el balance de tokens del contrato
        uint Balance = TokensDisponibles();
        // filtro para evaluer los tokens a comprar con los tokens dispoibles
        require(_numTokens <= Balance, "Compra en numero menor de tokens");
        // Transferencia de los tokens al comprador
        token.transfer(msg.sender, _numTokens);
        // Emitimos el evento de la compra
        emit ComprandoTokens(_numTokens, msg.sender);
    }

    // Balance de tokens en el contrato de loteria
    function TokensDisponibles() public view returns(uint){
        // regresamos la cantidad de tokens con la direccion del contrato
        return token.balanceOf(contrato);
    }

    // Obtener el balance de tokens acumulados en el bote
    function Bote() public view returns(uint) {
        // regresamos la cantidad de tokens en el bote el cual sera asignado al propietario del contrato
        return token.balanceOf(owner);
    }

    // Obtener el balance de tokens de una persona
    function MisTokens() public view returns(uint) {
        //Regresamos el numero de tokens de una persona 
        return token.balanceOf(msg.sender);
    }

    // ----------- Loteria ------------ //
    // Precio del boleto
    uint public PrecioBoleto = 5;
    // Relacion entre la persona que compra los boletos y los numeros de boletos 
    mapping(address => uint[]) idPersona_boletos;
    //Eelacion necesaria para identificar al ganador
    mapping(uint => address) ADN_boleto;
    //Numero aleatorio
    uint randNonce = 0;
    // Boletos generados
    uint [] boletos_comprados;
    // Eventos
    event boleto_comprado(uint, address); // Eventos cuando se compra un boleto
    event boleto_ganador(uint); // Evento del Ganador
    event tokens_devueltos(uint, address); //Devolucion de tokens

    /*
        - Ha sido necesario crear una funuin en ERC20.sol cin el nombre de transefrencia_loteria
        debido a que en caso de usar Trasfer o TransferFrom las direcciones que se escogian
        para realizar la transaccion eran equivocadas. Ya que el msg.sender que reciia el metodo Transfer o
        TransferFrom era la direccion de contrato. y debe ser la direccion de la persona fisica
    */
    // Funcion para comprar boletos de laloteria
    function ComprarBoleto(uint _boletos) public {
        //Precio total de los boletosa comprar
        uint precio_total = _boletos*PrecioBoleto;
        // Filtrdo de los tokens a pagar
        require(precio_total <= MisTokens(), "Necesitas comprar mas Tokens");
        //Transferencia de tokens al owner -> bote/premio
        token.transfencia_loteria(msg.sender, owner, precio_total);

        /*
            Lo que esta ara es tomar la marca de tiempo nown el msg.sender y un nonce
            (un numero que solo se utiliza e¿una vez para que ejecutemos dos vece la misma
            funcion de hash con los mismos parametros de entrada) en incremento.
            Luego se utiliza el keccak256 oara coonvertir estas entradas a u hash aleatorio,
            convertir este hash a un uint  y luegi utilizamos % 10000 para tomar los ultimos 4 digitos.
            dando un valor aleatorio entre 0 - 9999.
        */

        for(uint i = 0; i < _boletos; i++){
            uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 10000;
            randNonce++;
            // Almacenamos los datos de los boletos
            idPersona_boletos[msg.sender].push(random);
            // Numero de boleto comprado
            boletos_comprados.push(random);
            // Asignacion del ADN del boleto para tener un ganador
            ADN_boleto[random] = msg.sender;
            //Emision del evento
            emit boleto_comprado(random, msg.sender);
        }
    }

    //Visualizar el numero de voletos de una persona
    function TusBoletos() public view returns(uint[] memory){
        return idPersona_boletos[msg.sender];
    }

    // Funcion para generar un ganador e ingresarle los tokens
    function GenerarGanador() public Unicamente(msg.sender){
        //Debe haber boletos comprados para generar un ganador
        require(boletos_comprados.length > 0, "No hay Boletos comprados");
        //Declaracion de la longitud del array
        uint longitud = boletos_comprados.length;
        // Aleatoriamente elio un numero entre 0 - longitud
        // 1 - Eleccion de la posicion aleatoria del array
        uint poscicion_array = uint(uint(keccak256(abi.encodePacked(now))) % longitud);
        // 2 - Seleccion del numero aleatorio mediente la posicion del array
        uint eleccion = boletos_comprados[poscicion_array];
        // Emision del evento ganador
        emit boleto_ganador(eleccion);
        //recuparar la direccion del ganador
        address direccion_ganador = ADN_boleto[eleccion];
        // Enviarle los tokens del premio ganador
        token.transfencia_loteria(msg.sender, direccion_ganador, Bote());
    }

    //Devolucion de los tokens
    function DevolverTokens(uint _numTokens) public payable {
        // El numero de tokens a devolver debe ser mayor a 0 
        require(_numTokens > 0, "Necesitas devolver un umero positivo de tokens");
        // Wl usuario/vliente debe tener los tokens que desa devolver
        require(_numTokens <= MisTokens(), "No tienes los tokens que deseas devolver");
        //Devolucion:
        //1 - El cliente devuelve los tokens
        token.transfencia_loteria(msg.sender, address(this), _numTokens);
        //2 - La loteria paga los tokens devueltos en ethers
        msg.sender.transfer(PrecioTokens(_numTokens));
        // Emision del evento
        emit tokens_devueltos(_numTokens, msg.sender);
    }







}