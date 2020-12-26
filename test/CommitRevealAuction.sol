pragma solidity >=0.7.0 <0.8.0;

import "truffle/AssertBool.sol";
import "truffle/AssertBytes32.sol";
import "truffle/AssertString.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CommitRevealAuction.sol";

contract TestCommitRevealAuction {
    CommitRevealAuction auction = CommitRevealAuction(
        DeployedAddresses.CommitRevealAuction()
    );

    function testGetLotNameAfterDeploying() public {
        string memory expected = "Vase";
        bool expectedEnded = false;

        AssertString.equal(auction.lotName(), expected, "Getting lot name");
        AssertBool.equal(auction.ended(), expectedEnded, "Expect that auction is ended");
    }

    function testCommitBid() public {
        uint value = 500;
        bool fake = false;
        bytes32 secret = "1337";

        bool isEnded = auction.ended();
        bool isBiddingEnded = auction.isHappened(auction.biddingEnd());

        if (isEnded || isBiddingEnded) {
            return;
        }

        bytes32 blindedBid = keccak256(abi.encodePacked(value, fake, secret));
        auction.bid(blindedBid);

        bytes32 expectedBid = blindedBid;
        AssertBytes32.equal(auction.lastBid(), expectedBid, "Expect that bid was written");
    }

    function testRevealAndEndAuction() public {
        bool isRevealEnded = auction.isHappened(auction.revealEnd());
        bool isEnded = auction.ended();

        if (!isRevealEnded && !isEnded) {
            return;
        }

        uint[] memory values = new uint[](1);
        bool[] memory fakes = new bool[](1);
        bytes32[] memory secrets = new bytes32[](1);

        values[0] = uint(500);
        fakes[0] = false;
        secrets[0] = "1337";

        auction.reveal(values, fakes, secrets);

        isRevealEnded = auction.isHappened(auction.revealEnd());
        isEnded = auction.ended();
        if (!isRevealEnded || isEnded) {
            return;
        }
        auction.auctionEnd();

        bool expectedEnded = true;
        AssertBool.equal(auction.ended(), expectedEnded, "Expect that auction is ended");
    }
}
