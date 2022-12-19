const { ethers, run, network } = require("hardhat")

async function main() {
    const paymentFactory = await ethers.getContractFactory("payment")

    console.log("Deploying contract...")
    const payment = await paymentFactory.deploy()
    await payment.deployed()
    console.log(`Deployed contract to : ${payment.address}`)
    if (network.config.chainId === 5 && process.env.ETHERSCAN_API_KEY) {
        await payment.deployTransaction.wait(6)
        await verify(payment.address, [])
    }
}

async function verify(contractAddress, agrs) {
    console.log("Verifying contract...")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: agrs,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified!")
        } else {
            console.log(e)
        }
    }
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
