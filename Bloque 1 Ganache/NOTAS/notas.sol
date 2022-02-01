// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.0;
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;

//-------------------------------------
// ALUMNO   /     ID     /     NOTA
//-------------------------------------
// Marcos  |    77755N   |       5
// Joan    |    12345X   |       9
// Maria   |    02468T   |       2
// Martha  |    13579U   |       3
// Alba    |    98765Z   |       5

contract notas {
    // Direccion del profesor
    address public profesor;

    //constructor
    constructor() public {
        profesor = msg.sender;
    }

    // Mapping para relacionar el hash de la identidad del alumno con su nota del examen
    mapping (bytes32 => uint) Notas;

    // Array de los alumnos que pidan revisiones de examen
    string [] revisiones;

    // eventos
    event alumno_evaluado(bytes32);
    event evento_revision(string);

    // funcion para evaluar a un alumno
    function Evaluar( string memory _idAlumno, uint _nota) public UnicamenteProfesor(msg.sender){
        // Hash de la identificacion del alumno
        bytes32 hash_Alumno = keccak256(abi.encodePacked(_idAlumno));
        //Relacion entre el hash de la identificacio del alumno y su nota
        Notas[hash_Alumno] = _nota;
        // Emision del evento
        emit alumno_evaluado(hash_Alumno);
    }

    modifier UnicamenteProfesor(address _direccion) {
        require(_direccion == profesor, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    // Funcion para ver las notas del alumno
    function VerNotas(string memory _idAlumno) public view returns(uint) {
        // Hash de la identificacion del alumno
        bytes32 hash_Alumno = keccak256(abi.encodePacked(_idAlumno));
        //Devolver la nota del alumno
        return Notas[hash_Alumno];
    }

    //Funcion para padir una revision del examen
    function Revision(string memory _idAlumno) public {
        // Almacenamiento de la identidad del alumno en un array
        revisiones.push(_idAlumno);
        // emiion del evento
        emit evento_revision(_idAlumno);
    }

    //Funcion para ver los alumnos que a solicitado revision de examen
    function VerRevisiones() public view UnicamenteProfesor(msg.sender) returns(string [] memory) {
        // Devolver las identidades de los alumnos
        return revisiones;
    }
}