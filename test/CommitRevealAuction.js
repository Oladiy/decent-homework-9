const abi = require("ethereumjs-abi");
const ETHUtil = require("ethereumjs-util");
const ethers = require("ethers");
const Web3 = require("web3");

const CommitRevealAuction = artifacts.require("CommitRevealAuction");
const web3 = new Web3();

contract("CommitRevealAuction", accounts => {
    it("Check lot name after contract deploy", async () => {
        const auction = await CommitRevealAuction.deployed();

        const lotName = await auction.lotName.call();
        const expectedLotName = "Vase";

        assert.equal(lotName, expectedLotName);
    });

    it("Make bid if there is still bidding time and check if it was written", async () => {
        const auction = await CommitRevealAuction.deployed();

        const isBiddingEnd = await auction.isHappened.call(await auction.biddingEnd.call());
        const isEnd = await auction.ended.call();

        if (isBiddingEnd || isEnd) {
            return;
        }

        const value = 500;
        const fake = false;
        const secret = web3.utils.stringToHex("gu3$$wh4ts3cr3t");

        const blindedBid = web3.utils.soliditySha3(
            {t: "uint", v: new ETHUtil.BN(value)},
            {t: "bool", v: fake},
            {t: "bytes32", v: secret},
        );

        await auction.bid.call(blindedBid);
    });

    it("Reveal if its time", async () => {
        const auction = await CommitRevealAuction.deployed();

        const isRevealEnded = await auction.isHappened.call(await auction.revealEnd.call());
        const isEnded = await auction.ended.call();
        if (!isRevealEnded || isEnded) {
            return;
        }

        const values = [];
        const fakes = [];
        const secrets = [];

        values.push(500);
        fakes.push(false);
        secrets.push(web3.utils.stringToHex("1337"));

        await auction.reveal.call(values, fakes, secrets);
    });

    it("End auction if its time", async () => {
        const auction = await CommitRevealAuction.deployed();

        const isRevealEnded = await auction.isHappened.call(await auction.revealEnd.call());
        const isEnded = await auction.ended.call();
        if (!isRevealEnded || isEnded) {
            return;
        }

        assert.equal(await auction.highestBidder.call(), accounts[0]);

        await auction.end.call();

        const expectedEnded = true;
        assert.equal(await auction.ended.call(), expectedEnded)
    });
});
