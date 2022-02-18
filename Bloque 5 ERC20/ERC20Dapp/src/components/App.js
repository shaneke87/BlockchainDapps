import React, { Component } from 'react';
import './App.css';
import Web3 from 'web3';
import web3 from '../ethereum/web3';
import contrato_token from '../abis/main.json';

class App extends Component {

  async componentWillMount() {
    // Carga de Web3
    await this.loadWeb3();
    //Carga los datos de la blockchain
    await this.loadBlockchainData();
  }
  
  //Carga de Web3
  async loadWeb3(){
    if(window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
    } else if(window.web3){
      window.web3 = new Web3(window.web3.currentProvider);
    } else {
      window.alert('Non ethereum browser deteced. You should consider trying metamask!');
    }
  }
  
  //Carga los datos de la blockchain
  async loadBlockchainData() {
    const web3 = window.web3;
    // Carga de la cuenta
    const accounts = await web3.eth.getAccounts();
    this.setState({account: accounts[1]});
    console.log(this.state.account);
    const networkId = '97'; // id Ganache 5777, Binance Smart Chain testnet (BSC) 97
    console.log('networID: ', networkId);
    const networkData = contrato_token.networks[networkId];
    console.log('networkData: ', networkData);

    if(networkData) {
      const abi = contrato_token.abi;
      console.log('abi: ', abi)
      const address = networkData.address;
      console.log('address: ', address);
      const contract = new web3.eth.Contract(abi,address);
      this.setState({contract});
      // Direccion contrato
      const direccion_smart_contract = await this.state.contract.methods.getContract().call();
      console.log(direccion_smart_contract);
      this.setState({direccion_smart_contract});
      // Direccion del Dueño del smart contract
      const owner = await this.state.contract.methods.getOwner().call();
      console.log(owner);
      this.setState({owner});
      const num_tokens = await this.state.contract.methods.balance_total().call();
      console.log('Total de tokens en el contrato', num_tokens);
      this.setState({num_tokens});
    } else {
      window.alert("El smart contract no se ha desplegado en la red")
    }
  }

  constructor(props) {
    super(props);
    this.state = {
      account: '',
      contract: null,
      direccion_smart_contract: '',
      owner: '',
      direccion: '',
      cantidad: 0,
      loading: false,
      errorMessage:'',
      address_balance: '',
      num_tokens: 0
    }
  }

  // Funcion para realizar la compra de tokens
  envio = async (direccion, cantidad, ethers, mensaje) => {
    try {
      console.log(mensaje);
      const accounts = await web3.eth.getAccounts();
      await this.state.contract.methods.send_tokens(direccion, cantidad).send({from: accounts[0], value: ethers});
      
      
    } catch (err) {
      this.setState({errorMessage: err.message});
    } finally {
      this.setState({loading: false});
    }
  }

  // Funcion para incrementar la cantidad de tokens
  incremento_tokens = async (num_tokens, mensaje) => {
    try {
      console.log(mensaje);
      const accounts = await web3.eth.getAccounts();
      await this.state.contract.methods.GeneraTokens(num_tokens).send({from: accounts[0]});
      
      
    } catch (err) {
      this.setState({errorMessage: err.message});
    } finally {
      const balance_contrato = await this.state.contract.methods.balance_total().call();
      this.setState({num_tokens: balance_contrato});
      this.setState({loading: false});
    }
  }

  // fucncion que devuelve el balance de tokensse una persona
  balance_persona = async (address_balance, mensaje) => {
    try {
      console.log(mensaje);
      //balance de la persona
      const balance_direccion = await this.state.contract.methods.balance_direccion(address_balance).call();
      alert(parseFloat(balance_direccion));
      this.setState({address_balance: balance_direccion});
    } catch(e) {
      this.setState({errorMessage: e.message});
    } finally {
      this.setState({loading: false});
    }
  }

  // fucncion que devuelve el balance de tokens del contrato
  balance_contrato = async () => {
    try {
      console.log('Balance de contrato en ejecucion');
      //balance de la persona
      const balance_contrato = await this.state.contract.methods.balance_total().call();
      alert(parseFloat(balance_contrato));
    } catch(e) {
      this.setState({errorMessage: e.message});
    } finally {
      this.setState({loading: false});
    }
  }

  render() {
    return (
      <div>
        <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
          <a
            className="navbar-brand col-sm-3 col-md-2 mr-0"
            href="https://blockstellart.com"
            target="_blank"
            rel="noopener noreferrer"
          >
            DApp
          </a>
          <ul className='navbar-nav px-3'>
            <li className='nav-item text-nowrap d-none d-sm-none d-sm-block'>
              <small className='text-white'><span id='account'>{this.state.direccion_smart_contract}</span></small>
            </li>
          </ul>
        </nav>
        <div className="container-fluid mt-5">
          <div className="row">
            <main role="main" className="col-lg-12 d-flex text-center">
              <div className="content mr-auto ml-auto">
                <h1>Comprar Tokens ERC20</h1>
                <form onSubmit={(event) => {
                  event.preventDefault();
                  const direccion = this.direccion.value;
                  const cantidad = this.cantidad.value;
                  const ethers = web3.utils.toWei(this.cantidad.value, 'ether')
                  const mensaje = "Compra de tokens en ejecucion...";
                  this.envio(direccion,cantidad, ethers, mensaje);
                }}>

                  <input type="text" className='form-control mb-1' placeholder='Direccion de destino' ref={(input) => {this.direccion = input}} />
                  <input type="text" className='form-control mb-1' placeholder='Cantidad de tokens a comprar (1 ether -> 1 token)' ref={(input) => {this.cantidad = input}} />
                  <input type='submit' className='btn btn-block btn-danger btn-sm' value='COMPRAR TOKENS'/>
                </form>

                &nbsp;

                <h1>Balance total de tokens de un usuario</h1>
                <form onSubmit={(event) => {
                  event.preventDefault();
                  const direccion = this.address_balance.value;
                  const mensaje = "Balance de tokens de una persona en ejecucion...";
                  this.balance_persona(direccion, mensaje);
                }}>

                  <input type="text" className='form-control mb-1' placeholder='Direccion de destino' ref={(input) => {this.address_balance = input}} />
                  <input type='submit' className='btn btn-block btn-success btn-sm' value='BALANCE DE TOKENS'/>
                </form>

                &nbsp;

                <h1>Balance de Tokens de el Contrato</h1>

                <button className='btn btn-primary btn-block btn-sm' onClick={this.balance_contrato}>BALANCE CONTRATO</button>

                &nbsp;

                <form onSubmit={(event) => {
                  event.preventDefault();
                  const num_tokens = this.num_tokens.value;
                  const mensaje = "Incremento de tokens en ejecucion...";
                  this.incremento_tokens(num_tokens, mensaje);
                }}>
                  <input type="text" className='form-control mb-1' placeholder='Cantidad de tokens a Incrementar' ref={(input) => {this.num_tokens = input}} />
                  <input type='submit' className='btn btn-block btn-warning btn-sm' value='INCREMENTAR TOKENS'/>
                </form>

              </div>
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
