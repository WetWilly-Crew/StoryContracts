const hre = require("hardhat");

async function main() {
	// We get the contract to deploy
	const RoughWaters = await hre.ethers.getContractFactory("RoughWaters");
	const roughWaters = await RoughWaters.deploy();

	await roughWaters.deployed();

	console.log("RoughWaters deployed to:", roughWaters.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
