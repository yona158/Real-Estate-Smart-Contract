const voting = artifacts.require("RealEstate");

module.exports = function (deployer) {
  deployer.deploy(RealEstate);
};