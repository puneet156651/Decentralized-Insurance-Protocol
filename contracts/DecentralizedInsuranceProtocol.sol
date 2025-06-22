// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DecentralizedInsuranceProtocol {
    address public admin;

    struct Policy {
        address holder;
        uint256 premium;
        uint256 payout;
        uint256 validUntil;
        bool claimed;
    }

    mapping(address => Policy) public policies;

    event PolicyCreated(address indexed holder, uint256 premium, uint256 payout);
    event ClaimPaid(address indexed holder, uint256 payout);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createPolicy(uint256 _validDuration, uint256 _premium) external payable {
        require(msg.value == _premium, "Premium payment required");
        require(policies[msg.sender].holder == address(0), "Policy already exists");

        policies[msg.sender] = Policy({
            holder: msg.sender,
            premium: _premium,
            payout: _premium * 2,  // 2x coverage
            validUntil: block.timestamp + _validDuration,
            claimed: false
        });

        emit PolicyCreated(msg.sender, _premium, _premium * 2);
    }

    function claimInsurance() external {
        Policy storage policy = policies[msg.sender];
        require(policy.holder != address(0), "No policy found");
        require(block.timestamp <= policy.validUntil, "Policy expired");
        require(!policy.claimed, "Already claimed");

        policy.claimed = true;
        payable(msg.sender).transfer(policy.payout);

        emit ClaimPaid(msg.sender, policy.payout);
    }

    function fundPool() external payable onlyAdmin {
        // Admin can fund the insurance pool
    }
}
