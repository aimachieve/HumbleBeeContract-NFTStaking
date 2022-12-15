const { ethers } = require("hardhat");

async function main() {
    const sample = await ethers.getContractFactory("Sample");

    const contract = await sample.deploy();
    await contract.deployed();

    console.log('[Contract deployed to address:]', contract.address);
}

main().then(() => process.exit(0))
    .catch(err => {
        console.log('[deploy err]', err);
        process.exit(1);
    })