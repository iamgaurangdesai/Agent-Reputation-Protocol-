// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
}

/**
 * @title ARP EigenCloud Extension V2
 * @notice Fixed version - stores proof separately, doesn't call ARP directly
 */
contract ARPEigenCloudExtensionV2 {
    IAgentReputationProtocol public arp;
    
    enum VerificationType { NONE, EIGENAI_DETERMINISTIC, EIGENCOMPUTE_TEE, FULL_VERIFICATION }
    
    struct EigenCloudProof {
        bytes32 proofHash;
        VerificationType vType;
        uint256 timestamp;
        address agent;
        bool verified;
    }
    
    // taskId => proof
    mapping(uint256 => EigenCloudProof) public taskProofs;
    // agent => verification level
    mapping(address => VerificationType) public agentVerificationLevel;
    // agent => completed task count with proof
    mapping(address => uint256) public verifiedTaskCount;
    
    uint256 public constant EIGENAI_MULTIPLIER = 120;
    uint256 public constant EIGENCOMPUTE_MULTIPLIER = 150;
    uint256 public constant FULL_MULTIPLIER = 200;
    
    event ProofStored(uint256 indexed taskId, address indexed agent, bytes32 proofHash, VerificationType vType);
    event AgentVerificationUpgraded(address indexed agent, VerificationType newLevel);
    
    constructor(address _arp) { 
        arp = IAgentReputationProtocol(_arp); 
    }
    
    /**
     * @notice Store EigenAI proof for a task (FIXED - doesn't call ARP)
     * @param taskId The task ID
     * @param proofHash SHA256 hash of the proof
     * @param timestamp Unix timestamp
     */
    function storeEigenAIProof(uint256 taskId, bytes32 proofHash, uint256 timestamp) external {
        // Verify agent is registered on ARP
        (,,,,,, bool isRegistered) = arp.getAgent(msg.sender);
        require(isRegistered, "Agent not registered on ARP");
        
        // Store proof
        taskProofs[taskId] = EigenCloudProof({
            proofHash: proofHash,
            vType: VerificationType.EIGENAI_DETERMINISTIC,
            timestamp: timestamp,
            agent: msg.sender,
            verified: true
        });
        
        verifiedTaskCount[msg.sender]++;
        
        emit ProofStored(taskId, msg.sender, proofHash, VerificationType.EIGENAI_DETERMINISTIC);
    }
    
    /**
     * @notice Store full EigenCloud proof (TEE + AI)
     */
    function storeFullProof(uint256 taskId, bytes32 proofHash, bytes32 teeAttestation, uint256 timestamp) external {
        (,,,,,, bool isRegistered) = arp.getAgent(msg.sender);
        require(isRegistered, "Agent not registered on ARP");
        require(teeAttestation != bytes32(0), "Invalid TEE attestation");
        
        taskProofs[taskId] = EigenCloudProof({
            proofHash: keccak256(abi.encodePacked(proofHash, teeAttestation)),
            vType: VerificationType.FULL_VERIFICATION,
            timestamp: timestamp,
            agent: msg.sender,
            verified: true
        });
        
        agentVerificationLevel[msg.sender] = VerificationType.FULL_VERIFICATION;
        verifiedTaskCount[msg.sender]++;
        
        emit ProofStored(taskId, msg.sender, proofHash, VerificationType.FULL_VERIFICATION);
        emit AgentVerificationUpgraded(msg.sender, VerificationType.FULL_VERIFICATION);
    }
    
    /**
     * @notice Check if a task has a stored proof
     */
    function hasProof(uint256 taskId) external view returns (bool) {
        return taskProofs[taskId].verified;
    }
    
    /**
     * @notice Get proof details for a task
     */
    function getProof(uint256 taskId) external view returns (
        bytes32 proofHash,
        uint8 vType,
        uint256 timestamp,
        address agent,
        bool verified
    ) {
        EigenCloudProof memory p = taskProofs[taskId];
        return (p.proofHash, uint8(p.vType), p.timestamp, p.agent, p.verified);
    }
    
    /**
     * @notice Get boosted reputation score
     */
    function getBoostedReputation(address agent) external view returns (
        uint256 baseScore, 
        uint256 boostedScore, 
        uint256 multiplier, 
        VerificationType vLevel
    ) {
        (,,, uint256 reputationScore,,,) = arp.getAgent(agent);
        baseScore = reputationScore;
        vLevel = agentVerificationLevel[agent];
        
        if (vLevel == VerificationType.FULL_VERIFICATION) multiplier = FULL_MULTIPLIER;
        else if (vLevel == VerificationType.EIGENCOMPUTE_TEE) multiplier = EIGENCOMPUTE_MULTIPLIER;
        else if (vLevel == VerificationType.EIGENAI_DETERMINISTIC) multiplier = EIGENAI_MULTIPLIER;
        else multiplier = 100;
        
        boostedScore = (baseScore * multiplier) / 100;
    }
    
    /**
     * @notice Get agent stats
     */
    function getAgentStats(address agent) external view returns (
        uint256 verifiedTasks,
        VerificationType vLevel,
        uint256 currentMultiplier
    ) {
        verifiedTasks = verifiedTaskCount[agent];
        vLevel = agentVerificationLevel[agent];
        
        if (vLevel == VerificationType.FULL_VERIFICATION) currentMultiplier = FULL_MULTIPLIER;
        else if (vLevel == VerificationType.EIGENCOMPUTE_TEE) currentMultiplier = EIGENCOMPUTE_MULTIPLIER;
        else if (vLevel == VerificationType.EIGENAI_DETERMINISTIC) currentMultiplier = EIGENAI_MULTIPLIER;
        else currentMultiplier = 100;
    }
}
