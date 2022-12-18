const hre = require("hardhat");


const main = async function (hre) {
    const {deployments, getNamedAccounts} = hre;

    const {deployer} = await getNamedAccounts();

    await deployments.deploy('POC', {
        from: deployer,
        log: true,
    });
};


module.exports = main;
main.tags = ["POC"];
