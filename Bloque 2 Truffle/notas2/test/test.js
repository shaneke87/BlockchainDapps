// llamada al cotrato del Sisitema Univeritario
const notas = artifacts.require('notas');

contract('notas', accounts => {
    it('1. Funcion Evaluar(string memory _asignatura, string memory _idAlumno, uint _nota)', async () => {
        // Smart Contract Desplegado
        let instance = await notas.deployed();
        // Llamada al metodo de evaluacion del Smart Contract
        const tx1 = await instance.Evaluar('Matematicas','12345X', 9, {from: accounts[0]});
        const tx2 = await instance.Evaluar('Biologia','12345X', 8, {from: accounts[0]});
        // imprimir valores
        console.log(accounts[0]); // Direccion del Profesor
        console.log(tx1 );          // Trransaccion de la evaluacion academica
        console.log(tx2 );          // Trransaccion de la evaluacion academica
        // Comprobacion de la informacion de la Blockchain
        const nota_alumno1 = await instance.VerNotas.call('Matematicas','12345X', {from: accounts[1]});
        const nota_alumno2 = await instance.VerNotas.call('Biologia','12345X', {from: accounts[1]});
        // Condicion para pasar el test: nota_alumno = 9
        console.log(nota_alumno1);
        console.log(nota_alumno2);
        assert.equal(nota_alumno1, 9);
        assert.equal(nota_alumno2, 8);

    });

    it('2. Funcion: Revision(string memory _asignatura, string memory _idAlumno)', async () => {
        // Smart Contract Desplegado
        let instance = await notas.deployed();
        // llamada al metodo revisar los examenes
        let rev = await instance.Revision('Biologia','12345X', {from: accounts[1]});
        // Imprimir los valores recibidos de la revision
        console.log(rev);
        // Verificacion del test
        const id_alumno = await instance.VerRevisiones.call('Biologia',{from: accounts[0]});
        console.log(id_alumno);
        // Comprobaciones de los dato de las revisiones
        assert.equal(id_alumno, '12345X')

    });
});