import "@nomicfoundation/hardhat-ethers";
import hre from "hardhat";
import { expect } from "chai";

describe("Voting", function () {
    async function deployVotingFixture() {
        const connection = await hre.network.getOrCreate();
        const ethers = connection.ethers;

        const candidates = ["Alice", "Bob", "Charlie"];
        const [owner, voter1, voter2, voter3] = await ethers.getSigners();

        const Voting = await ethers.getContractFactory("Voting");
        const voting = (await Voting.deploy(candidates)) as any;

        return { voting, candidates, owner, voter1, voter2, voter3 };
    }

    describe("Deployment", function () {
        it("Should set the right candidates", async function () {
            const { voting, candidates } = await deployVotingFixture();
            for (let i = 0; i < candidates.length; i++) {
                const [name, voteCount] = await voting.getCandidate(BigInt(i));
                expect(name).to.equal(candidates[i]);
                expect(voteCount).to.equal(0);
            }
        });
        it("Should set the deployer as owner", async function () {
            const { voting, owner } = await deployVotingFixture();
            expect(await voting.owner()).to.equal(owner.address);
        });
    });

    describe("Voting", function () {
        it("Should allow a voter to vote", async function () {
            const { voting, voter1 } = await deployVotingFixture();

            await voting.connect(voter1).vote(0n);

            const [, voteCount] = await voting.getCandidate(0n);
            expect(voteCount).to.equal(1n);
        });

        it("Should not allow a voter to vote twice", async function () {
            const { voting, voter1 } = await deployVotingFixture();

            await voting.connect(voter1).vote(0n);
            await expect(voting.connect(voter1).vote(0n))
                .to.be.revertedWithCustomError(voting, "AlreadyVoted");
        });

        it("Should not allow voting for an invalid candidate", async function () {
            const { voting, voter1 } = await deployVotingFixture();

            await expect(voting.connect(voter1).vote(99n))
                .to.be.revertedWithCustomError(voting, "InvalidCandidate");
        });

        it("Should track votes correctly across multiple voters", async function () {
            const { voting, voter1, voter2, voter3 } = await deployVotingFixture();

            await voting.connect(voter1).vote(0n);
            await voting.connect(voter2).vote(0n);
            await voting.connect(voter3).vote(1n);

            const [, aliceVotes] = await voting.getCandidate(0n);
            const [, bobVotes] = await voting.getCandidate(1n);

            expect(aliceVotes).to.equal(2n);
            expect(bobVotes).to.equal(1n);
        });
    });
});