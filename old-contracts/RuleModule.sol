// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./interfaces/IRuleInterface.sol";
import "./structs/Structs.sol";
import "./RuleExample.sol";

contract RuleModule {
    mapping(uint256 => address) public rules;
    uint256 public ruleCount;
    address public smartNotary;

    constructor(address _smartNotary) {
        smartNotary = _smartNotary;
        RuleExample re = new RuleExample(
            "client needs to be accepted",
            _smartNotary
        );
        addRule(address(re));
    }

    function getAllRules() public view returns (address[] memory) {
        address[] memory list = new address[](ruleCount);
        for (uint256 i = 0; i < ruleCount; i++) {
            list[i] = rules[i];
        }
        return list;
    }

    function addRule(address _ruleAddress) public {
        require(msg.sender == smartNotary, "Only Smart Notary");
        ruleCount += 1;
        rules[ruleCount - 1] = _ruleAddress;
    }

    function _checkRule(IRuleInterface rule, address _smartClient)
        private
        returns (RuleResult memory)
    {
        return rule.checkRule(_smartClient);
    }

    function checkAllRules(address _smartClient)
        public
        returns (RuleResult memory results)
    {
        for (uint256 i = 0; i < ruleCount; i++) {
            IRuleInterface rule = IRuleInterface(rules[i]);
            RuleResult memory result = _checkRule(rule, _smartClient);
            if (!result.respected) {
                return result;
            }
        }
        RuleResult memory okResult = RuleResult({
            respected: true,
            reason: "all good"
        });
        return okResult;
    }
}
