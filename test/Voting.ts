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
        const voting = await Voting.deploy(candidates);

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
});