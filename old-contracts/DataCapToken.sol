// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


//THAT is a mock datacap token made only for the context of the hackathon.
// it is needed to ease the process of testing and to play around easier with the app.

contract DataCapToken is ERC20 {

    address private smartNotary;
    constructor() ERC20("DataCap Token", "DCT"){
        smartNotary = msg.sender;
    }

    function mint(address _to, uint256 _value) public {
        require(msg.sender == smartNotary, "Only the owner can mint tokens");
        require(_value > 0, "Value must be positive");
        _mint(_to, _value);
    }

    function  getSmartNotary() public view returns (address){
        return smartNotary;
    }
}
