const {expect} = require('chai')
const {ethers} = require('hardhat')
const {Contract, providers, utils} = require('ethers')

const smartNotaryAbi =
    require('../contracts/artifacts/SmartNotary.json').abi

const SMART_NOTARY_ADDRESS = ''
let smartNotary = null
//TODO complete
describe('Smart Notary Tests', function () {
    it('test Deployment', async function () {
        this.timeout(5 * 60 * 1000)
        const SmartNotary = await ethers.getContractFactory('SmartNotary')
        smartNotary = await SmartNotary.deploy()
        await smartNotary.deployed()
        // console.log(smartNotary)
        console.log('Smart Notary deployed at:' + smartNotary.address)
        expect(smartNotary.address).to.be.not.undefined
    })

    it.skip('test getOwner', async () => {
        const owner = await smartNotary.getOwner()
        expect(owner).to.equal('0x921c7f9be1e157111ba023cba7bc29e66b85a940')
    })
    it('test createSmartClient', async () => {
        // I should send FIL in this
        const client = await smartNotary
            .createSmartClient(
                '0x39806bDCBd704970000Bd6DB4874D6e98cf15123',
                '0x74657374',
                ['0x0036', false]
            )
           
        console.log('client', client)
        //expect(client).to.equal('0x921c7f9be1e157111ba023cba7bc29e66b85a940')
    })
})
