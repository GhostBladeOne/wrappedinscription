import { deployContract } from "../test/shared/utilities"

const { ethers } = require('hardhat')

async function main() {
	const accounts = await ethers.getSigners()

	for (const account of accounts) {
		console.log('Account address:' + account.address)
	}

	let deployer = accounts[0]
	console.log('deployer:' + deployer.address)
	// We get the contract to deploy
	console.log('Account balance:', (await deployer.getBalance()).toString())


  const txhash = '0xd893ca77b3122cb6c480da7f8a12cb82e19542076f5895f21446258dc473a7c2';
	const WrappedInscription = await deployContract('StakeInscription', [txhash])

	console.log("WrappedInscription : %s", WrappedInscription.address)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
