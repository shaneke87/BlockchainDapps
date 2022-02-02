const Notas = artifacts.require("notas");

module.exports = function (deployer) {
  deployer.deploy(Notas);
};
