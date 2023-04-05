// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./lib/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";
import "./SmartClient.sol";
import "./RuleModule.sol";
import "./DataCapToken.sol";

/**
FOR SIMPLICITY NOTARY WILL STAKE the same amount of FIL for each clients
not1: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
not2: 0x1C9E05B29134233e19fbd0FE27400F5FFFc3737e
deployer: 0x921c7f9be1e157111bA023CBa7bC29e66B85A940
client owner: 0x39806bDCBd704970000Bd6DB4874D6e98cf15123
*/


contract SmartNotary {
    address payable private owner;
    address[] public smartClients;
    mapping(address => bool) public clientOwnerHasSmartClients;
    mapping(address => bool) public simpleNotaries;
    mapping(address => bool) public acceptedClients;
    mapping(address => uint256) public notariesToStakes; //map each notary to the staked amount of fil
    address public ruleModule;
    address public dataCapToken;

    uint256 private totalValueStaked;

    event NotaryAdded(address indexed _notary);
    event TestEvent(address indexed addr);
    event Staked(
        address indexed notary,
        address indexed smartClient,
        uint256 nOfNotaries
    );
    event DataCapAllocated(address indexed _smartClient, uint256 amount);

    constructor() {
        owner = payable(msg.sender);
        simpleNotaries[0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266] = true; // just for teasting
        simpleNotaries[0x1C9E05B29134233e19fbd0FE27400F5FFFc3737e] = true; // just for teasting
        ruleModule = address(new RuleModule(address(this)));
        DataCapToken dtc = new DataCapToken();
        dataCapToken = address(dtc);
    }

    function emitTestEvent() public {
        emit TestEvent(msg.sender);
    }

    function updateRuleModule(address _ruleModule) public {
        require(msg.sender == owner);
        ruleModule = _ruleModule;
    }

    function getOwner() public view returns (address payable) {
        return owner;
    }

    function getSmartClients() public view returns (address[] memory) {
        return smartClients;
    }

    function isSmartClientAccepted(address _smartClient)
        public
        view
        returns (bool)
    {
        return acceptedClients[_smartClient];
    }

    // Adds a simple notary to this contract.
    // Simple notaries are people/organization who take responsibility over presented clients
    function addSimpleNotary() public {
        require(
            !simpleNotaries[address(msg.sender)],
            "Notary is already registered"
        );
        // idea 💡 here can be added some logic to accept or not the notary
        simpleNotaries[address(msg.sender)] = true;
        emit NotaryAdded(address(msg.sender));
    }

    // allows notaries to present new clients to the protocol
    function createSmartClient(
        address _clientOwner,
        string memory _name,
        BigInt memory _fullDcAmount
    ) public payable {
        require(msg.value >= 1, "required 1 wei");
        require(simpleNotaries[address(msg.sender)], "Only Notaries");
        require(
            !clientOwnerHasSmartClients[_clientOwner],
            "Client Already Proposed"
        );

        //create client
        SmartClient smartClient = new SmartClient(
            //notaries,
            _fullDcAmount,
            _clientOwner,
            address(this),
            _name
        );
        smartClient.addNotary(payable(msg.sender));
        smartClients.push(address(smartClient));
        clientOwnerHasSmartClients[_clientOwner] = true;

        // notary stake FIl -review
        notariesToStakes[msg.sender] += msg.value;
        totalValueStaked += msg.value;
        payable(address(this)).transfer(msg.value);

        //add the client to this contract
        emit Staked(msg.sender, address(smartClient), 1);
    }

    // allows notaries to stake on clients already proposed
    function supportSmartCLient(address _smartClient) public payable {
        require(msg.value >= 1, "required 1 wei");
        require(simpleNotaries[address(msg.sender)], "Only Notaries");
        require(
            !acceptedClients[_smartClient],
            "Smart Client is already accepted"
        );
        //TODO CHECK that the notary didnt staked on this
        SmartClient smartClient = SmartClient(_smartClient);
        bool isNotaryAlreadyStaking = smartClient.isNotaryStakingHere(
            msg.sender
        );
        require(!isNotaryAlreadyStaking, "Notary already staked");

        smartClient.addNotary(payable(msg.sender));

        notariesToStakes[msg.sender] += msg.value;
        totalValueStaked += msg.value;
        payable(address(this)).transfer(msg.value);

        uint256 nOfNotaries = smartClient.getnotaries().length;

        emit Staked(msg.sender, _smartClient, nOfNotaries);
    }

    function grantFirstRoundDataCap(address _smartClient) public {
        require(msg.sender == owner, "Only owner"); //owner of this contract
        require(!acceptedClients[_smartClient], "Already granted"); //owner of this contract

        //first make the client accepted
        acceptedClients[_smartClient] = true;

        // grantDatacap
        SmartClient smartClient = SmartClient(address(_smartClient));
        BigInt memory totDcRequested = smartClient.getTotalAllowanceRequested();
        grantDataCap(_smartClient, 100, totDcRequested);
        emit DataCapAllocated(msg.sender, 100);
    }

    // grant datacap to SmartClients when they need it
    function grantDataCap(
        address _smartClient,
        uint256 _value,
        BigInt memory _dataCap
    ) public {
        DataCapToken dc = DataCapToken(dataCapToken);
        dc.mint(_smartClient, _value);
    }

    // this function grants datacap to client and pay fees to protocol and notaries
    function refillDatacap(BigInt memory _dataCap) public {
        require(acceptedClients[msg.sender], "Only Smart Client");
        grantDataCap(msg.sender, 100, _dataCap);
        emit DataCapAllocated(msg.sender, 100);
    }

    //for now just check if the smart Client is accepted
    function checkRefill() public returns (RuleResult memory) {
        RuleModule rm = RuleModule(ruleModule);
        return rm.checkAllRules(msg.sender);
    }

    function withdrawAll() public {
        string memory mess1 = "Only owner can withdraw tokens.";
        require(msg.sender == owner, mess1);

        address payable payableSender = payable(msg.sender);
        uint256 amount = address(this).balance;
        payableSender.transfer(amount);
    }
}
