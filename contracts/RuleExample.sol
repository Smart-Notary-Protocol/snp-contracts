// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./interfaces/IRuleInterface.sol";
import "./SmartNotary.sol";

//example rule: the Smart Client should be accepted
contract RuleExample is IRuleInterface {
    string private name;
    address private smartNotary;

    constructor(string memory _name, address _smartNotary) {
        name = _name;
        smartNotary = _smartNotary;
    }

    function checkRule(address _smartClient) external view override returns (RuleResult memory) {
        SmartNotary sm = SmartNotary(smartNotary);
        bool isAccepted = sm.isSmartClientAccepted(_smartClient);
        RuleResult memory res = RuleResult({respected: isAccepted, reason: "test"});
        return res;
    }

    function getName() external view override returns (string memory){
        return name;
    }
}
