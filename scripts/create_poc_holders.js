const hre = require("hardhat");


async function main() {
    const signers = await ethers.getSigners();
    const deployed = await hre.deployments.all();

    const POC = await hre.ethers.getContractFactory("POC");
    const poc = await POC.attach(deployed.POC.address);

    const Auction = await hre.ethers.getContractFactory("POCAuction");
    const auction = await Auction.attach(deployed.POCAuction.address);

    signers.forEach(async (signer) => {
        const pocWithSigner = await poc.connect(signer);
        const balance = await poc.balanceOf(signer.address);
        console.log(`Account ${signer.address} has ${balance} $POC`);
    });
}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
