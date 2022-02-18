const hre = require("hardhat");

async function main() {
	// We get the contract to deploy
	const RoughWaters = await hre.ethers.getContractFactory("RoughWaters");
	const roughWaters = await RoughWaters.deploy();

	await roughWaters.deployed();

	await roughWaters.updateScenario(9, 9);
	await roughWaters.setChoicesSequences(
		[0,1,2,3,4,5,6,7,8],
		[2,2,2,3,4,5,7,8,9]
	);
	await roughWaters.setChoicesOptions(
		[0,1,2,3,4,5,6,7,8],
		[2,2,2,3,2,3,2,2,3]
	);

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
