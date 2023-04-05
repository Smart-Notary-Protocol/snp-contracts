// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "../structs/Structs.sol";


interface IRuleInterface {
    function checkRule(address _smartClient) external returns (RuleResult memory);
    function getName() external returns (string memory name);
}