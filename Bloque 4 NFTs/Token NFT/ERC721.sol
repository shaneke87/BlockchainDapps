// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.6.0;

interface IERC165 {
    // interface que se implementara para el NFT ERC721 como se comenta en la 
    // documentacion oficial para generar un NFT es obligatorio esta interface
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

pragma solidity ^0.5.0;

contract IERC721 is IERC165 {
    // Evento que se dispara al realizarse una transferencia
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    // Evento que se dispara cuando se aprueba la compra del NFT del dueño al aprobado por la compra
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    // evento de un dueño de una serie de tokens pueda validar las transacciones que se tienen pendientes con un resultado booleano
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Retorna el balance de NFT den la cuenta del owner
    function balanceOf(address owner) public view returns(uint balance);

    // devuelve el dueño de un token especifico pasado por parametro 
    function ownerOf(uint tokenId) public view returns(address owner);

    // transferir un NFT especifico desde una cuenta from hasta una cuenta to
    // from y to no pueden ser cero y el token debe ser del dueño (from)
    function safeTransferFrom(address from, address to, uint tokenId) public;

    //transferencia que no requiere que seas el dueño se utilizaran los metodoa approve y setApproveForAll para poder realizar la transferencia
    function transferFrom(address from, address to, uint tokenId) public;
    // fucncion para transferir un NFT y se aprueve aun si no soy el propietario
    function approve(address to, uint tokenId) public;
    //obtener a partir del NFT la direccion de quienn esta generando la transaccion
    function getApproved(uint tokenId) public view returns(address operator);

    //generar la aprovacion a para un operador
    function setApprovalForAll(address operador, bool _approved) public;
    //validar las transferencias entre el dueño del token y el operador
    function isApprovedForAll(address owner, address operador) public view returns(bool);

    //funcion para transferir igual que safeTransferFrom solo que se añade mas informacion para que vaya al bloque de la cadena
    function safeTransferFrom(address from, address to, uint tokenId, bytes memory data) public;

}

pragma solidity ^0.5.0;

contract IERC721Receiver {
    //gestiona la recepcion de un NFT
    // se recibira la transferencia de formasegura con el metodo de esta interfaz 
    // hasta que el receptor tenga en su poder el NFT
    function onERC721Received(address operador, address from, uint tokenId, bytes memory data) public returns(bytes4);
}

pragma solidity ^0.5.0;

library SafeMath{
    // Restas
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      require(a<=b, "SafeMath: Subtraction Overflow");
      return a - b;
    }
    
    // Sumas
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c>=a,"SafeMath: Addition Overflow");
      return c;
    }
    
    // Multiplicacion
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    //Division
    function div(uint a, uint b) internal pure returns(uint256) {
        require(b>a, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    //Modulo
    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b!=0, "SafeMath: modulo by Zero");
        return a%b;
    }
}

pragma solidity ^0.5.0;

library Address {
    function isContract(address account) internal view returns(bool) {
        uint256 size;

        assembly { size := extcodesize(account)}
        return size > 0;
    }
}

pragma solidity ^0.5.0;

library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value;
    }

    function current(Counter storage counter) internal view returns(uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

pragma solidity ^0.5.0;

contract ERC165 is IERC165 {
    //se genera el identificador del smartcontact co bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    //mapaing para relacionar los smartcontracts soportados por la IERC165
    mapping(bytes4 => bool) private _supportedInterfaces;

    //constructor
    constructor() internal {
        // metodo usuado dentro del constructor para registrare asi mismo cono ERC165
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    // Se emplea el metodo de la IERC165 para validar si esta soportado el smart contract que se le introduzca como parametro
    function supportsInterface(bytes4 interfaceId) external view returns(bool) {
        //regresamos el booleano que este asociado a la interfaceId con el mapping _supportdInterfaces
        return _supportedInterfaces[interfaceId];
    }

    // funcion para poder registrar quien qiera implemaentar el ERC165
    function _registerInterface(bytes4 interfaceId) internal {
        // se requeire que que el interfaceId no sea 0xffffffff, si lo es no se registrara
        require(interfaceId != 0xffffffff, "ERC165: Invalid interfacce ID");
        // Si pasa el require se manda al mapping en true
        _supportedInterfaces[interfaceId] = true;
    }
}

pragma solidity ^0.5.0;

contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    //Identificador del Smart Contract
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    //Mapping del token id relacionado con la direccion del dueño del token
    mapping(uint => address) private _tokenOwner;

    //mapping para relacionar el token id con quien esta aprovado para utilizar el token
    mapping(uint => address) private _tokenApprovals;

    // Mapping que relaciona la direccion del dueño con el numero de tokens que posee
    mapping(address => Counters.Counter) private _ownedTokensCount;

    //Mapping que relaiona la direccion del dueño con un mapping de personas que estan aprovadas para el uso del token
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
    */

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor() public {
        //Registrar el soporte d conforme el ERC721 desde el ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    //Obtener el balance de una deireccion especificada como parametro
    function balanceOf(address owner) public view returns(uint) {
        //se requiere que el owned no sea una direccion bacia
        require(owner != address(0), "ERC721: Balance query for the zero address");
        // devolvemos el numero de tokens asociado a la direccion del dueño
        return _ownedTokensCount[owner].current();
    }

    // Obtener el dueño del un token mediante el tokenid intoducido por parametro
    function ownerOf(uint tokenId) public view returns(address) {
        // obtenemos la direccion del owner mediante el tokenId
        address owner = _tokenOwner[tokenId];
        // requerimos que la direccion del owner no venga vacia
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        //retornamos el owner si no viene vacio
        return owner;
    }

    // funcion que aprueba a otra direccion  transferir el token dado 
    function approve(address to, uint256 tokenId) public {
        // scamos el dueño del token
        address owner = ownerOf(tokenId);
        // requiere que la direccion de destino sea diferente a la del owner
        require(to != owner, "ERC721: approval to current owner");
        //requeire que quien mande el token sea el dueño o alguen aprobado paramanejar el token
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");
        //camboa el token aprobado del dueño actual a la direccion que se mandara
        _tokenApprovals[tokenId] = to;
        // emision del evento Approval
        emit Approval(owner, to, tokenId);
    }

    //funcion que te permite saber quien es la persoa aprovada pra manejar un token mediante el id token
    function getApproved(uint256 tokenId) public view returns(address) {
        //requeiere que el token exista para poder consultarlo
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        //regresa la direccion de quein est aprobado para operar el token
        return _tokenApprovals[tokenId];
    }

    // funcion que permite dar los permisos necesarios para que un operator pueda mover un token de un owner
    function setApprovalForAll(address to, bool approved) public {
        // requiere que el que ejecute la funcion no sea la misma direccion para aprovar
        require(msg.sender != to, "ERC721: approve to caller");
        // medinte el mapping _operatorApproval se da los permisos a la direccion to
        _operatorApprovals[msg.sender][to] = approved;
        // emitimos el evento donde aprobamos al operador para el token
        emit ApprovalForAll(msg.sender, to, approved);
    }

    // funcion que regresa u booleano y permite saber si el operator esta aprovado para tratar el token del owner
    function isApprovedForAll(address owner, address operator) public view returns(bool) {
        // se regresa el booleano dado por el mapping _operatorApprovals(address => mapping(address => bool))
        return _operatorApprovals[owner][operator];
    }

    //funcion  que transfiere un token de una direccion(dueño o aprovado) a otra direccion to
    function transferFrom(address from, address to, uint256 tokenId) public {
        // requeire que sea un operador aprovado o el dueño para poder realizar la tranferencia
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller not owner nor approved");
        //se reealiza la transferencia de el dueño o operador aprovado a la nueva direccion
        _transferFrom(from,to,tokenId);
    }

    //funcion para tranferir de forma segura de una direccion origen a una direccio destino 
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    //funcion para generar la transferencia segura de un origen a un destino incluyendo datos extras como quie es el destinatario y el origen
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        // Se realiza la transferencia del oreigen al destino
        transferFrom(from, to, tokenId);
        // requerimos que se implemente el check del receptor del ERC721
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    //regresa un booleano indicando si el token existe
    function _exists(uint256 tokenId) internal view returns (bool) {
        // se valida la direccion del token si existe
        address owner = _tokenOwner[tokenId];
        // se regresa un booleano si la direccion es correcta true si esta vacia false
        return owner != address(0);
    }

    //validar si una direccion esta aprovada o es la dueña del token
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool) {
        //requiere validad si el token existe
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        // obtenemos al dueños del token
        address owner = ownerOf(tokenId);
        //regresamos si el vendedor es el dueño o su es un operador aprovado para manejar el token
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // Funcion para mintear un NFT
    function _mint(address to, uint256 tokenId) internal {
        // Se requiere que la direccion to (el dueño) no este vacia
        require(to != address(0), "ERC721: mint to the zero address");
        // Se requeire que el tokenId no exista
        require(!_exists(tokenId), "ERC721: token alredy minted");

        // se genera la relacion entre el tokenId y el dueño del NFT (quien lo mintea)
        _tokenOwner[tokenId] = to;
        // se incrementa en 1 la cantidad de tokens que posee la direccion que esta minteando
        _ownedTokensCount[to].increment();

        // Emitimos el evento de tranferencia del NFT
        emit Transfer(address(0), to, tokenId);
    }

    // Funcion de quemado de los tokens
    function _burn(address owner, uint256 tokenId) internal {
        // Se requiere que el dueño del tokenId sea el mismo que se paa por parametro
        require(ownerOf(tokenId) == owner, "ERC721: Burn of token that is not own");
        // desvinculamos el tokenId de cualquier porpietario
        _clearApproval(tokenId);
        // decrementamos en 1 la cantidad de tokenId que tiene la direccion pasada por parametro
        _ownedTokensCount[owner].decrement();
        // se desasocia el tokenId de la direccion dueña del tokenId
        _tokenOwner[tokenId] = address(0);

        //Emitimos el evento Transfer para indicar el quemado del tokenId
        emit Transfer(owner, address(0), tokenId);
    }

    // Funcion simplificada para el proceso de quemado solo se paa por parametro el tokenId
    function _burn(uint256 tokenId) internal {
        // Se implementa la funcion de burn de arriba
        _burn(ownerOf(tokenId), tokenId);
    }

    // funcion para tranferir un token de la direccion del dueño o delegado a la direccion que recibe el token
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        // se requiere que el el dueño o delegado tengan el token en su poder
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        //se requeire que la direccio que recibe no este vacia
        require(to != address(0), "ERC721: transfer to de Zero address");

        // se limpia la direccion aptrobada para el token
        _clearApproval(tokenId);

        //se decfrementa el numero de tokens de la persona que evnia la tranferencia
        _ownedTokensCount[from].decrement();
        // se incrementa el numero de tokens de quien recive el token en tranferencia
        _ownedTokensCount[to].increment();

        // Se transiere el token a la direccion que recive
        _tokenOwner[tokenId] = to;

        // Se emite el evento de transferencia del origen al destino
        emit Transfer(from, to, tokenId);
    }

    //fucncion que permite asegurarnos que la transferencia se realizo de forma correcta y segura
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns(bool) {
        //si la direccion no es un contrato listo para recibir el token enviamos true
        if(!to.isContract()) {
            return true;
        }

        // generamos el numero que identifique a la constante de recepcion sea igual para con ello marcar la transferencia como exitosa
        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    // Fucncion qur limpia a las personas aprovadas para el manejo de los tokens
    function _clearApproval(uint256 tokenId) private {
        if(_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }

}

pragma solidity ^0.5.0;

contract IERC721Enumerable is IERC721 {
    // Funcio que regresa la cantifad de tokens que hay
    function totalSupply() public view returns(uint256);
    // funcion que regresa al tokenId pasando por parametro la direccion del dueño y el index del token
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns(uint256 tokenId);
    //funcion que regresa el token id apartir del index del token
    function tokenByIndex(uint256 index) public view returns(uint256);
}

pragma solidity ^0.5.0;

contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
    //mapping que relaciona una direccion con los tokenid que posee
    mapping(address => uint256[]) private _ownedTokens;

    //mapping que relaciona el tokenid con el index de la lista de tokens existentes del dueño
    mapping(uint256 => uint256) private _ownedTokensIndex;

    //arreglo de todos los tokens existentes
    uint256[] private _allTokens;

    //Mapping que relaciona el tokenId con el index en la lista de todos los tokens
    mapping(uint256 => uint256) private _allTokensIndex;

     /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    // cosntructor
    constructor() public {
        // registramos el contracto en el ERC165 para que este doportada la interfaz del contrato
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }
    
    // funcion que devuelve el tokenId ingresando por parametro el dueño y el index del token
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns(uint256) {
        // se requiere que el indice pasado por parametro no sea mayor a el balance del dueño
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bunds");
        //retornamos el tokenId solicitado
        return _ownedTokens[owner][index];
    }

    //Funcion qu regresa el total de tokens que hay en el smart contract
    function totalSupply() public view returns(uint256) {
        return _allTokens.length;
    }

    // funcion que regresa el tokenId de la lista general de tokens dada por index
    function tokenByIndex(uint index) public view returns(uint256) {
        // se requiere que el index no sea mayor a el totalSupply del smart contract
        require(index < totalSupply(), "ERC721Enumerable: global Index out of Bounds");
        // Regresamos el tokenId
        return _allTokens[index];
    } 

    //fucncion interna para realizar una transferencia del origen al destino
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        // Utilizamos el metodo del contrato padre ERC721 para ejecutar la transferencia
        super._transferFrom(from, to, tokenId);

        // removemos al dueño del token de el mapping que relaciona el dueño con el tokenId
        _removeTokenFromOwnerEnumeration(from, tokenId);
        //Agregammos al nuevo dueño al mapping que relacona la direccion con el tokenId
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    // funcion que mintea un nuevo token
    function _mint(address to, uint256 tokenId) internal {
        //de el contrato padre aplicamos el metodo _mint para realizar el minteo del token
        super._mint(to, tokenId);
        //añadimos el roken a la lista enumerable de quien recibe el token
        _addTokenToOwnerEnumeration(to, tokenId);
        // añadimos el token a la lista general enumerable
        _addTokenToAllTokensEnumeration(tokenId);
    }

    // Funcion que quema un token especifico
    function _burn(address owner, uint256 tokenId) internal {
        // llamamos el metodo de el contrato padre ERC721
        super._burn(owner, tokenId);
        // Se remueve de la lista del dueño del token
        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // se limpia de lista del propietario del token asignandosele un 0
        _ownedTokensIndex[tokenId] = 0;
        // se remueve de la lista general el token
        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    //funcion que regresa la lista de los tokens que tiene u propietario
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    //funcionque añade al mapping de direccion y lista de tokens
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        // relacionamos el tokenId a el index de la lista de tokens del propietario
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        // añadimos el tokenId a la lista de tokens de quein recibe el token
        _ownedTokens[to].push(tokenId);
    }

    // Funcion que añade el token a la lista general de tokens
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        // relacionamos el rokenid con el index que tomara en la lista
        _allTokensIndex[tokenId] = _allTokens.length;
        // añadimos el token a la lista general
        _allTokens.push(tokenId);
    }

    //Funcion que remueve el token del dueño actual
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        //sacamos el index del ultimo token de la direccion que envia
        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        // debemos saber cual es el index del token en la lista del dueño
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // si el tokenId que se va a borrar no es el ultimo se realiza esta accion para corregir 
        //la lista y madar el token a eliminar al final de la lista
        if(tokenIndex != lastTokenIndex) {
            //sacamos el ultimo tokenid de quien envia
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            //Movemos el token en la ultima posicion a la posicion vacia del token eliminado
            _ownedTokens[from][tokenIndex] = lastTokenId;
            // Actualizamos el index del token que se movio
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        // borramos el ultimo index de la lista de tokens de quein envia
        _ownedTokens[from].length--;
    }

    // funcion que remueve el token de la lista general de tokens
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        //sacamos el index del ultimo token de la lista general
        uint256 lastTokenIndex = _allTokens.length.sub(1);
        // debemos saber cual es el index del token en la lista general
        uint256 tokenIndex = _allTokensIndex[tokenId];

        //sacamos el ultimo tokenid de la lista general
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        //Movemos el token en la ultima posicion a la posicion vacia del token eliminado
        _allTokens[tokenIndex] = lastTokenId;
        // Actualizamos el index del token que se movio
        _allTokensIndex[lastTokenId] = tokenIndex;

        // borramos el ultimo index de la lista de tokens de la lista general
        _allTokens.length--;
        // mandamos a cero el tokenid que se borro
        _allTokensIndex[tokenId]  = 0;
    }
}

pragma solidity ^0.5.0;

contract IERC721Metadata is IERC721 {
    //funcion que devuelve el nombre del nft
    function name() external view returns( string memory);
    //fucncion que devuelve el sibolo del nft
    function symbol() external view returns(string memory);
    // funcion que devuelve la uri del token
    function tokenURI(uint256 tokenId) external view returns(string memory);
}


pragma solidity ^0.5.0;

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    // Nombre del token
    string private _name;
    // Nombre del Simbolo
    string private _symbol;
    // opcional mapping para las URIs de los tokens
    mapping(uint256 => string) private _tokenURIs;

     /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */

    // Identificador unico para registrar el contrato
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    //constructor
    constructor(string memory name, string memory symbol) public {
        //asignamos los parametros a las variables privadas del contrato
        _name = name;
        _symbol = symbol;

        // Registramos el contracto con el identificador unico generado
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    //Se impleenta elmmetodo name de la interfaz IERC721Metadata
    function name() external view returns(string memory) {
        return _name;
    }

    // se implementa el metodo symbol de la interfaz IERC721Metadata
    function symbol() external view returns(string memory) {
        return _symbol;
    }

    // se implementa el metodo tokenURI de la interfaz IERC721Metadata
    function tokenURI(uint256 tokenId) external view returns(string memory) {
        //se requiere que el tokenId exista
        require(_exists(tokenId), "ERC721Metadata: URI ser nonexistent token");
        return _tokenURIs[tokenId];
    }

    //fucncion que implementa el mapping de el tokenURI
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        //se requiere que el tokenId exista
        require(_exists(tokenId), "ERC721Metadata: URI ser nonexistent token");
        // relacionamos con el maping el tokenId con su uri
        _tokenURIs[tokenId] = uri;
    }

    // funcion de borrado de la metadata del nft
    function _burn(address owner, uint256 tokenId) internal {
        // aplicamos la el metodo del contrato padre ERC721
        super._burn(owner, tokenId);

        //limpamos la metadata
        if(bytes(_tokenURIs[tokenId]).length != 0){
            delete _tokenURIs[tokenId];
        }
    }

}

pragma solidity ^0.5.0;

// contrato que implementa toda la funcionalidad de los contratos pata el nft
contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }
}