// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@zondax/filecoin-solidity/contracts/v0.8/DataCapAPI.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/types/DataCapTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import {AccountTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/AccountTypes.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";

import "@zondax/filecoin-solidity/contracts/v0.8/VerifRegAPI.sol";
import {VerifRegTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/VerifRegTypes.sol";

import "./MockClient.sol";
import {FilAddresses} from "@zondax/filecoin-solidity/contracts/v0.8/utils/FilAddresses.sol";
import {BigInts} from "@zondax/filecoin-solidity/contracts/v0.8/utils/BigInts.sol";

using CommonTypes for CommonTypes.FilAddress;
using CommonTypes for CommonTypes.BigInt;
using DataCapTypes for DataCapTypes.TransferParams;

/**
💡 IDEA:
Create a Smart-Notary contract which is a notary, has datacap.
it:
creates new clients
checks client Score and allocate datacap basing on score
KEEP IT SIMPLE

Note that, once deployed, this contract need to become a notary

from filecoin.sol I need to:
create a verified client --> AddVerifiedClient
grant datacap --> IncreaseAllowance
*/

contract SmartNotary {
    address public owner;
    mapping(address => bool) public clients;
    uint256 clientCount;
    string public sym;
    CommonTypes.FilAddress public testAddress;
    CommonTypes.BigInt public balance; // use BigInts.toUint256 utility to convert

    uint64 public constant AUTHENTICATE_MESSAGE_METHOD_NUM = 2643134072;
    uint64 public constant DATACAP_RECEIVER_HOOK_METHOD_NUM = 3726118371;
    uint64 public constant MARKET_NOTIFY_DEAL_METHOD_NUM = 4186741094;
    uint64 public constant INCREASE_ALLOWANCE_METHOD_NUM = 1777121560;
    address public constant MARKET_ACTOR_ETH_ADDRESS =
        address(0xff00000000000000000000000000000000000005);
    address public constant DATACAP_ACTOR_ETH_ADDRESS =
        address(0xfF00000000000000000000000000000000000007);

    event ClientCreated(address indexed addr);
    event AllowanceGranted(address indexed to, uint256 amount);
    event DatacapReceived(string received);

    constructor() {
        owner = address(msg.sender);
    }

    function getNotaryBalance() public returns (CommonTypes.BigInt memory) {
        CommonTypes.FilAddress memory addr = FilAddresses.fromEthAddress(
            address(this)
        );
        balance = DataCapAPI.balance(addr);
        return balance;
    }

    // create client:
    // call AddVerifiedClient
    function createClient(address clientAddress, uint256 allowance) public {
        MockClient client = new MockClient(address(msg.sender));
        clients[address(client)] = true;
        clientCount += 1;

        VerifRegTypes.AddVerifiedClientParams memory params = VerifRegTypes
            .AddVerifiedClientParams(
                FilAddresses.fromEthAddress(clientAddress),
                BigInts.fromUint256(allowance)
            );

        VerifRegAPI.addVerifiedClient(params);
        emit ClientCreated(address(msg.sender));
    }

    // increaseAmount should be calculated in this function, depending on the score of the client
    function grantDataCap(address addr, uint256 increaseAmount) public {
        require(clients[msg.sender], "client is not verified");

        DataCapTypes.IncreaseAllowanceParams memory params = DataCapTypes
            .IncreaseAllowanceParams(
                FilAddresses.fromEthAddress(addr),
                BigInts.fromUint256(increaseAmount)
            );

        DataCapAPI.increaseAllowance(params);
        emit AllowanceGranted(addr, increaseAmount);
    }

    // just used to receive datacap
    function handle_filecoin_method(
        uint64 method,
        uint64,
        bytes memory params
    ) public returns (uint32, uint64, bytes memory) {
        bytes memory ret;
        uint64 codec;
        // dispatch methods
        receiveDataCap(params);
        return (0, codec, ret);
    }

    function receiveDataCap(bytes memory params) internal {
        require(
            msg.sender == DATACAP_ACTOR_ETH_ADDRESS,
            "msg.sender needs to be datacap actor f07"
        );
        //TODO: Add datacap received to balance
        emit DatacapReceived("DataCap Received!");
    }
}
