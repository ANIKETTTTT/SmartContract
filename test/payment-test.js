const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers")
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs")
const { expect } = require("chai")

describe("payment", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    it("Should create payment platform", async function () {
        const Payment = await ethers.getContractFactory("payment")
        const payment = await Payment.deploy()
        await payment.deployed()

        await payment.createPlan(1, 1)
        let plans = await payment.plans(0)
        console.log(plans)
    })
})
