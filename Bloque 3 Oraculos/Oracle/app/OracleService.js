const Web3 = require('web3');
const Tx = require('ethereumjs-tx').Transaction;
const fetch = require('node-fetch');

// Llamada a los archivos .json
const constactJson = require('../build/contracts/Oracle.json');

// Instncia de web3
const web3 = new Web3('ws://127.0.0.1:7545');

//Informacion de direcciones de Ganche
const addressContract = '0xdC29752217cd7C807a7cd6EB101d4D956876ABc0';
const contractInstance = new web3.eth.Contract(constactJson.abi, addressContract);
const privateKey = Buffer.from('98f66079c0b76c4cb09c5a80ea5f47d51582a5bd95ef1df92f929ba18b7eb246', 'hex');
const address = '0x8B388a01aa2461639d49FF21CebB4b97D1F353e8';

// obtener el numero de bloque
web3.eth.getBlockNumber().then(n => listenEvent(n-1));

// fucncion: listenEvent
function listenEvent(lastBlock) {
    contractInstance.events.__callbackNewData({}, {fromBlock: lastBlock, toBlock: 'latest'}, (err, event) => {
        event ? updateData():null;
        err ? console.log(err):null;
    });
}

//Funcion: updateData
function updateData(){
    //start_date = 2015-09-07
    //end_date = 2015-09-08
    //api_key = DEMO_KEy
    const url = 'https://api.nasa.gov/neo/rest/v1/feed?start_date=2015-09-07&end_date=2015-09-08&api_key=DEMO_KEY';

    fetch(url)
        .then(response => response.json())
        .then(json => setDataContract(json.element_count));
}

// Funcion: setDataContract(_value)
function setDataContract(_value) {
    web3.eth.getTransactionCount(address, (err, txNum) => {
        contractInstance.methods.setNumberAsteroids(_value )
            .estimateGas({}, (err, gasAmount) => {
                let rawTx = {
                    nonce: web3.utils.toHex(txNum),
                    gasPrice: web3.utils.toHex(web3.utils.toWei('1.4', 'gwei')),
                    gasLimit: web3.utils.toHex(gasAmount),
                    to: addressContract,
                    value: '0x00',
                    data: contractInstance.methods.setNumberAsteroids(_value).encodeABI()
                }

                const tx = new Tx(rawTx);
                tx.sign(privateKey);
                const serializedTx = tx.serialize().toString('hex');
                web3.eth.sendSignedTransaction('0x'+serializedTx);

            })
    })
}