// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SepoliaMultiApprovalPayout {
    address public approverA;
    address public approverB;
    address public approverC;

    address payable public recipient;

    mapping(address => bool) public approved;
    bool public executed;

    event Approved(address indexed approver);
    event Executed(address indexed executor, uint256 amount, address recipient);
    event Deposited(address indexed sender, uint256 amount);

    constructor(
        address _A,
        address _B,
        address _C,
        address payable _recipient
    ) {
        approverA = _A;
        approverB = _B;
        approverC = _C;
        recipient = _recipient;
        executed = false;
    }

    modifier onlyApprovers() {
        require(
            msg.sender == approverA ||
            msg.sender == approverB ||
            msg.sender == approverC,
            "Not an authorized approver"
        );
        _;
    }

    function approve() external onlyApprovers {
        approved[msg.sender] = true;
        emit Approved(msg.sender);
    }

    function isConsensusReached() public view returns (bool) {
        return approved[approverA] && approved[approverB] && approved[approverC];
    }

    function executeAction(uint256 amountInWei) external onlyApprovers {
        require(!executed, "Already executed");
        require(isConsensusReached(), "Consensus not reached");
        require(address(this).balance >= amountInWei, "Insufficient contract balance");

        executed = true;
        recipient.transfer(amountInWei);

        emit Executed(msg.sender, amountInWei, recipient);
    }

    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Deposited(msg.sender, msg.value);
    }
}
