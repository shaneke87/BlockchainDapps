// llamada al cotrato del Sisitema Univeritario
const notas = artifacts.require('notas');

contract('notas', accounts => {
    it('1. Funcion Evaluar( string memory _idAlumno, uint _nota)', async () => {
        // Smart Contract Desplegado
        let instance = await notas.deployed();
        // Llamada al metodo de evaluacion del Smart Contract
        const tx = await instance.Evaluar('12345X', 9, {from: accounts[0]});
        // imprimir valores
        console.log(accounts[0]); // Direccion del Profesor
        console.log(tx);          // Trransaccion de la evaluacion academica
        // Comprobacion de la informacion de la Blockchain
        const nota_alumno = await instance.VerNotas.call('12345X', {from: accounts[1]});
        // Condicion para pasar el test: nota_alumno = 9
        console.log(nota_alumno);
        assert.equal(nota_alumno, 9);

    });

    it('2. Funcion: Revision(string memory _idAlumno)', async () => {
        // Smart Contract Desplegado
        let instance = await notas.deployed();
        // llamada al metodo revisar los examenes
        let rev = await instance.Revision('12345X', {from: accounts[1]});
        // Imprimir los valores recibidos de la revision
        console.log(rev);
        // Verificacion del test
        const id_alumno = await instance.VerRevisiones.call({from: accounts[0]});
        console.log(id_alumno);
        // Comprobaciones de los dato de las revisiones
        assert.equal(id_alumno, '12345X')

    });
});