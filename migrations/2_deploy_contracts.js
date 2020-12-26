const CommitRevealAuction = artifacts.require("CommitRevealAuction");

module.exports = function (deployer) {
    deployer.deploy(CommitRevealAuction);
};