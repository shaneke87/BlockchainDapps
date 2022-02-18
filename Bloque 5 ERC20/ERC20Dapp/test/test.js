// llamada al contrato
const main = artifacts.require('main');

contract('main', accounts => {
    it('Funcion: getOwner()', async () => {
        // Smart contract desplegado
        let instance = await main.deployed();
        console.log("Accounts[0]: ", accounts[0]);
        console.log("Direccion del Owner: ", accounts[0]);
        const direccionOwner = await instance.getOwner.call();
        assert.equal(accounts[0], direccionOwner)
    });

    it('Funcion: send_tokens(address _destinatario, uint256 _numTokens)', async () => {
        // Smart contract desplegado
        let instance = await main.deployed();4
        //Balance incial
        inicial_balance_direccion = await instance.balance_direccion.call(accounts[0]);
        inicial_balance_contrato = await instance.balance_total.call();
        console.log("Balance contrato", inicial_balance_contrato);
        console.log("Balance de accounts[0]: ",inicial_balance_direccion);
        // envio de tokens
        await instance.send_tokens(accounts[0],10, {from: accounts[0]});
        // Balance hecho una ves transaccion
        balance_direccion = await instance.balance_direccion.call(accounts[0]);
        balance_contrato = await instance.balance_total.call();
        console.log("Balance contrato", balance_contrato);
        console.log("Balance de accounts[0]: ",balance_direccion);

        //verificaciones
        assert.equal(balance_direccion, parseInt(inicial_balance_direccion) + 10)
        assert.equal(balance_contrato, parseInt(inicial_balance_contrato) - 10)



    })
})