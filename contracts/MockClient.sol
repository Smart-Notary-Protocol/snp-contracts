// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract MockClient {
    address public owner;

    address public constant MARKET_ACTOR_ETH_ADDRESS =
        address(0xff00000000000000000000000000000000000005);
    address public constant DATACAP_ACTOR_ETH_ADDRESS =
        address(0xfF00000000000000000000000000000000000007);
    uint64 public constant DATACAP_RECEIVER_HOOK_METHOD_NUM = 3726118371;
    uint64 public constant ADD_VERIFIER_CLIENT_METHOD_NUM = 3916220144;

    event DatacapReceived(string received);
    event Verified(string verified);

    constructor(address _clientOwner) {
        owner = _clientOwner;
    }

    // just used to receive datacap
    function handle_filecoin_method(
        uint64 method,
        uint64,
        bytes memory params
    )
        public
        returns (
            uint32,
            uint64,
            bytes memory
        )
    {
        bytes memory ret;
        uint64 codec;
        // dispatch methods
        if (method == DATACAP_RECEIVER_HOOK_METHOD_NUM) {
            receiveDataCap(params);
        } else if (method == ADD_VERIFIER_CLIENT_METHOD_NUM) {
            emit Verified("This client is verified"); //TODO HANDLE
        } else {
            revert("the filecoin method that was called is not handled");
        }
        return (0, codec, ret);
    }

    function receiveDataCap(bytes memory params) internal {
        require(
            msg.sender == DATACAP_ACTOR_ETH_ADDRESS,
            "msg.sender needs to be datacap actor f07"
        );
        emit DatacapReceived("DataCap Received!");
        // Add get datacap balance api and store datacap amount
    }
}
