const hre = require("hardhat");


const main = async function (hre) {
    const {deployments, getNamedAccounts} = hre;

    const {deployer} = await getNamedAccounts();
    const deployed = await hre.deployments.all();

    await deployments.deploy('POCAuction', {
        from: deployer,
        args: [deployed.POC.address],
        log: true,
    });
};


module.exports = main;
main.tags = ["POCAuction"];
