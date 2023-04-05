// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./lib/filecoin-solidity/contracts/v0.8/DataCapAPI.sol";
import "./lib/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";
import "./SmartNotary.sol";
import "./structs/Structs.sol";

contract SmartClient {
    //TODO review visibility
    string public name;
    address payable private smartNotary; // the SmartNotary contract who initialized this Client
    address payable[] public notaries; // list of notaries who accepted this client. can be setted only at contract initialization
    address public clientOwner; // the address of the owner of this contract
    mapping(address => bool) public notariesSet; // needed to map notaries

    BigInt private totalAllowanceRequested; // the full DC amount requested by this contract
    BigInt public dataCapThreshold; //should be 25/100
    // uint currentBalance; useless, can use balance from datacap actor/api
    uint256 private datacapFee = 1000000000000000000; // 10^18 wei 


    
    // event DealInitialized(uint256 amount);
    // event DealDenied(bytes reason);

    constructor(
        BigInt memory _totalAllowanceRequested,
        address _clientOwner,
        address _smartNotary,
        string memory _name
    ) {
        clientOwner = _clientOwner;
        totalAllowanceRequested = _totalAllowanceRequested;
        smartNotary = payable(_smartNotary);
        name = _name;
    }

    function getTotalAllowanceRequested() public view returns (BigInt memory) {
        return totalAllowanceRequested;
    }

    function getnotaries() public view returns (address payable[] memory) {
        return notaries;
    }

    function isNotaryStakingHere(address addr) public view returns (bool) {
        return notariesSet[addr];
    }

    function addNotary(address payable notary) public {
        notaries.push(notary);
        notariesSet[notary] = true;
    }


    // function getBalance() public returns (BigInt memory balance) {
    //     return _getBalance();
    // }

    // function _getBalance() internal returns (BigInt memory balance) {
    //     bytes memory addr = abi.encodePacked(address(this));
    //     balance = DataCapAPI.balance(addr);
    //     return balance;
    // }

    // this function is needed to claim the datacap (invoked by the owner or notaries)
    // at the end set isDataCapClaimable to false
    function claimDataCap() public payable returns (bool) {
        require(msg.sender == clientOwner, "Only Owner");
        require(msg.value >= datacapFee, "Fee too low");

        SmartNotary sn = SmartNotary(address(smartNotary));

        //check if is claimable
        RuleResult memory check = sn.checkRefill();
        require(check.respected, "Datacap not claimable");

        sn.refillDatacap(totalAllowanceRequested);

        uint256 feeForProtocol = (msg.value * 5) / 100; // 5% of fee
        smartNotary.transfer(feeForProtocol);

        uint256 totFeeForNotaries = msg.value - feeForProtocol;
        uint256 feeForEachNotary = totFeeForNotaries / notaries.length;

        require(totFeeForNotaries >= feeForEachNotary * notaries.length);
        for (uint256 i = 0; i < notaries.length; i++) {
            notaries[i].transfer(feeForEachNotary);
        }
    }

    function convert(bytes20 _0xAddress)
        public
        pure
        returns (bytes memory f4Address)
    {

    }

    function makeDeal(BigInt memory _requestedAmount) public {
      
    }
}
