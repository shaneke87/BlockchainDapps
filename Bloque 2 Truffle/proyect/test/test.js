Hello = artifacts.require("hello");

contract("hello", accounts => {
    it("funcion getMessage: Obtener Mensaje", async () => {
        let instance = await Hello.deployed();
        const message = await instance.getMessage.call({from: accounts[0]});
        assert.equal(message, "Hola Mundo");
    });

    it('funcion setMessage: Cambiar Mensaje', async () => {
        let instance = await Hello.deployed();
        const tx = await instance.setMessage('Oscar');
        console.log(accounts);
        console.log(accounts[2]);
        console.log(tx);
        const msg = await instance.getMessage.call();
        assert.equal(msg, 'Oscar');
    });
});