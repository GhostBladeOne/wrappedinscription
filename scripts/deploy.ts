import { ethers } from "hardhat";

async function main() {
    const token = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

    const wrappedInscription = await ethers.deployContract("WrappedInscription", [token], {
    });

    await wrappedInscription.waitForDeployment();

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
