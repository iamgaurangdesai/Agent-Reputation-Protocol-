// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAgentReputationProtocol {
    function getAgent(address agentAddress) external view returns (
        string memory name,
        string memory bio,
        string[] memory skills,
        uint256 reputationScore,
        uint256 tasksCompleted,
        uint256 stakeAmount,
        bool isRegistered
    );
    function completeTask(uint256 taskId, string calldata solution) external;
}

contract ARPEigenCloudExtension {
    IAgentReputationProtocol public arp;
    
    enum VerificationType { NONE, EIGENAI_DETERMINISTIC, EIGENCOMPUTE_TEE, FULL_VERIFICATION }
    
    struct EigenCloudProof {
        bytes32 proofHash;
        VerificationType vType;
        uint256 timestamp;
        bool verified;
    }
    
    mapping(uint256 => EigenCloudProof) public taskProofs;
    mapping(address => VerificationType) public agentVerificationLevel;
    
    uint256 public constant EIGENAI_MULTIPLIER = 120;
    uint256 public constant EIGENCOMPUTE_MULTIPLIER = 150;
    uint256 public constant FULL_MULTIPLIER = 200;
    
    event TaskCompletedWithProof(uint256 indexed taskId, address indexed agent, bytes32 proofHash, VerificationType vType);
    event AgentVerificationUpgraded(address indexed agent, VerificationType newLevel);
    
    constructor(address _arp) { arp = IAgentReputationProtocol(_arp); }
    
    function completeTaskEigenAI(uint256 taskId, string calldata solution, bytes32 proofHash, uint256 timestamp) external {
        (,,,,,, bool isRegistered) = arp.getAgent(msg.sender);
        require(isRegistered, "Agent not registered");
        
        taskProofs[taskId] = EigenCloudProof(proofHash, VerificationType.EIGENAI_DETERMINISTIC, timestamp, true);
        arp.completeTask(taskId, solution);
        
        emit TaskCompletedWithProof(taskId, msg.sender, proofHash, VerificationType.EIGENAI_DETERMINISTIC);
    }
    
    function getBoostedReputation(address agent) external view returns (uint256 baseScore, uint256 boostedScore, uint256 multiplier, VerificationType vLevel) {
        (,,, uint256 reputationScore,,,) = arp.getAgent(agent);
        baseScore = reputationScore;
        vLevel = agentVerificationLevel[agent];
        
        if (vLevel == VerificationType.FULL_VERIFICATION) multiplier = FULL_MULTIPLIER;
        else if (vLevel == VerificationType.EIGENCOMPUTE_TEE) multiplier = EIGENCOMPUTE_MULTIPLIER;
        else if (vLevel == VerificationType.EIGENAI_DETERMINISTIC) multiplier = EIGENAI_MULTIPLIER;
        else multiplier = 100;
        
        boostedScore = (baseScore * multiplier) / 100;
    }
}
