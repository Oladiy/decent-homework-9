const CommitRevealAuction = artifacts.require("CommitRevealAuction");

module.exports = function (deployer) {
    deployer.deploy(CommitRevealAuction, 10, 20, "0xC9c4dB81f75643FAeb5e38CF3a303578bfe6788b", "Vase");
};