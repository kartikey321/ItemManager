const SharedWallet = artifacts.require("ItemManager");

module.exports = function (deployer) {
  deployer.deploy(SharedWallet);
};
