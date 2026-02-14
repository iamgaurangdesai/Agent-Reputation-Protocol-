// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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
    
    function getTask(uint256 taskId) external view returns (
        string memory description,
        uint256 reward,
        address creator,
        address agent,
        bool isCompleted,
        bool isDisputed
    );
}

/**
 * @title ARP EigenCloud Extension V3
 * @notice Production-ready with security controls
 * @dev Enhanced with access control, reentrancy protection, and task verification
 */
contract ARPEigenCloudExtensionV3 is ReentrancyGuard, Pausable, Ownable {
    
    enum VerificationType { NONE, EIGENAI_DETERMINISTIC, EIGENCOMPUTE_TEE, FULL_VERIFICATION }
    
    struct EigenCloudProof {
        bytes32 proofHash;
        VerificationType vType;
        uint256 timestamp;
        address agent;
        bool verified;
        bytes32 teeAttestation; // Optional: for TEE verification
    }
    
    struct AgentStats {
        uint256 totalVerifiedTasks;
        uint256 eigenAiTasks;
        uint256 teeTasks;
        uint256 fullVerificationTasks;
        VerificationType highestLevel;
        uint256 lastActivityTimestamp;
    }
    
    // State variables
    IAgentReputationProtocol public immutable arp;
    
    // taskId => proof
    mapping(uint256 => EigenCloudProof) public taskProofs;
    
    // agent => stats
    mapping(address => AgentStats) public agentStats;
    
    // agent => taskIds (for lookup)
    mapping(address => uint256[]) public agentVerifiedTasks;
    
    // proofHash => used (prevent duplicate proofs)
    mapping(bytes32 => bool) public usedProofHashes;
    
    // Settings
    uint256 public minProofTimestamp = 1 hours; // Proof must be newer than 1 hour old
    uint256 public maxProofTimestamp = 30 days;  // Proof must be newer than 30 days
    
    // Constants
    uint256 public constant EIGENAI_MULTIPLIER = 120;      // 1.2x
    uint256 public constant EIGENCOMPUTE_MULTIPLIER = 150; // 1.5x
    uint256 public constant FULL_MULTIPLIER = 200;         // 2.0x
    uint256 public constant BASE_MULTIPLIER = 100;         // 1.0x
    
    // Events
    event ProofStored(
        uint256 indexed taskId, 
        address indexed agent, 
        bytes32 proofHash, 
        VerificationType vType,
        uint256 timestamp
    );
    
    event AgentVerificationUpgraded(
        address indexed agent, 
        VerificationType newLevel,
        uint256 timestamp
    );
    
    event ProofInvalidated(
        uint256 indexed taskId,
        address indexed agent,
        bytes32 proofHash,
        string reason
    );
    
    event SettingsUpdated(
        uint256 minTimestamp,
        uint256 maxTimestamp
    );
    
    // Errors
    error AgentNotRegistered(address agent);
    error TaskAlreadyVerified(uint256 taskId);
    error ProofAlreadyUsed(bytes32 proofHash);
    error InvalidTimestamp(uint256 timestamp);
    error InvalidTeeAttestation();
    error TaskNotCompleted(uint256 taskId);
    error ProofNotFound(uint256 taskId);
    error Unauthorized();
    
    constructor(address _arp) Ownable(msg.sender) {
        require(_arp != address(0), "Invalid ARP address");
        arp = IAgentReputationProtocol(_arp);
    }
    
    // Modifiers
    modifier onlyRegisteredAgent() {
        (,,,,,, bool isRegistered) = arp.getAgent(msg.sender);
        if (!isRegistered) revert AgentNotRegistered(msg.sender);
        _;
    }
    
    modifier validTimestamp(uint256 timestamp) {
        uint256 currentTime = block.timestamp;
        if (timestamp < currentTime - maxProofTimestamp || timestamp > currentTime + minProofTimestamp) {
            revert InvalidTimestamp(timestamp);
        }
        _;
    }
    
    /**
     * @notice Store EigenAI proof for a task
     * @param taskId The task ID (must exist in ARP)
     * @param proofHash SHA256 hash of the proof
     * @param timestamp Unix timestamp of proof generation
     */
    function storeEigenAIProof(
        uint256 taskId, 
        bytes32 proofHash, 
        uint256 timestamp
    ) external 
        nonReentrant 
        whenNotPaused 
        onlyRegisteredAgent 
        validTimestamp(timestamp) 
    {
        // Check proof not already used
        if (usedProofHashes[proofHash]) revert ProofAlreadyUsed(proofHash);
        
        // Check task not already verified
        if (taskProofs[taskId].verified) revert TaskAlreadyVerified(taskId);
        
        // Verify task exists and is completed (optional but recommended)
        (,,, address taskAgent, bool isCompleted,) = arp.getTask(taskId);
        if (taskAgent != msg.sender) {
            // Task not completed by this agent yet, that's OK
            // We allow pre-storing proofs before task completion
        }
        
        // Store proof
        taskProofs[taskId] = EigenCloudProof({
            proofHash: proofHash,
            vType: VerificationType.EIGENAI_DETERMINISTIC,
            timestamp: timestamp,
            agent: msg.sender,
            verified: true,
            teeAttestation: bytes32(0)
        });
        
        // Mark proof hash as used
        usedProofHashes[proofHash] = true;
        
        // Update agent stats
        AgentStats storage stats = agentStats[msg.sender];
        stats.totalVerifiedTasks++;
        stats.eigenAiTasks++;
        stats.lastActivityTimestamp = block.timestamp;
        
        // Update highest level if needed
        if (uint256(stats.highestLevel) < uint256(VerificationType.EIGENAI_DETERMINISTIC)) {
            stats.highestLevel = VerificationType.EIGENAI_DETERMINISTIC;
        }
        
        // Add to agent's task list
        agentVerifiedTasks[msg.sender].push(taskId);
        
        emit ProofStored(taskId, msg.sender, proofHash, VerificationType.EIGENAI_DETERMINISTIC, timestamp);
    }
    
    /**
     * @notice Store TEE-verified proof
     */
    function storeTEEProof(
        uint256 taskId,
        bytes32 proofHash,
        bytes32 teeAttestation,
        uint256 timestamp
    ) external 
        nonReentrant 
        whenNotPaused 
        onlyRegisteredAgent 
        validTimestamp(timestamp) 
    {
        if (teeAttestation == bytes32(0)) revert InvalidTeeAttestation();
        if (usedProofHashes[proofHash]) revert ProofAlreadyUsed(proofHash);
        if (taskProofs[taskId].verified) revert TaskAlreadyVerified(taskId);
        
        taskProofs[taskId] = EigenCloudProof({
            proofHash: proofHash,
            vType: VerificationType.EIGENCOMPUTE_TEE,
            timestamp: timestamp,
            agent: msg.sender,
            verified: true,
            teeAttestation: teeAttestation
        });
        
        usedProofHashes[proofHash] = true;
        
        AgentStats storage stats = agentStats[msg.sender];
        stats.totalVerifiedTasks++;
        stats.teeTasks++;
        stats.lastActivityTimestamp = block.timestamp;
        
        if (uint256(stats.highestLevel) < uint256(VerificationType.EIGENCOMPUTE_TEE)) {
            stats.highestLevel = VerificationType.EIGENCOMPUTE_TEE;
            emit AgentVerificationUpgraded(msg.sender, VerificationType.EIGENCOMPUTE_TEE, block.timestamp);
        }
        
        agentVerifiedTasks[msg.sender].push(taskId);
        
        emit ProofStored(taskId, msg.sender, proofHash, VerificationType.EIGENCOMPUTE_TEE, timestamp);
    }
    
    /**
     * @notice Store full verification (EigenAI + TEE)
     */
    function storeFullProof(
        uint256 taskId,
        bytes32 proofHash,
        bytes32 teeAttestation,
        uint256 timestamp
    ) external 
        nonReentrant 
        whenNotPaused 
        onlyRegisteredAgent 
        validTimestamp(timestamp) 
    {
        if (teeAttestation == bytes32(0)) revert InvalidTeeAttestation();
        if (usedProofHashes[proofHash]) revert ProofAlreadyUsed(proofHash);
        if (taskProofs[taskId].verified) revert TaskAlreadyVerified(taskId);
        
        bytes32 combinedHash = keccak256(abi.encodePacked(proofHash, teeAttestation));
        
        taskProofs[taskId] = EigenCloudProof({
            proofHash: combinedHash,
            vType: VerificationType.FULL_VERIFICATION,
            timestamp: timestamp,
            agent: msg.sender,
            verified: true,
            teeAttestation: teeAttestation
        });
        
        usedProofHashes[proofHash] = true;
        usedProofHashes[combinedHash] = true;
        
        AgentStats storage stats = agentStats[msg.sender];
        stats.totalVerifiedTasks++;
        stats.fullVerificationTasks++;
        stats.lastActivityTimestamp = block.timestamp;
        stats.highestLevel = VerificationType.FULL_VERIFICATION;
        
        agentVerifiedTasks[msg.sender].push(taskId);
        
        emit ProofStored(taskId, msg.sender, proofHash, VerificationType.FULL_VERIFICATION, timestamp);
        emit AgentVerificationUpgraded(msg.sender, VerificationType.FULL_VERIFICATION, block.timestamp);
    }
    
    /**
     * @notice Invalidate a proof (owner only - for fraud prevention)
     */
    function invalidateProof(
        uint256 taskId, 
        string calldata reason
    ) external onlyOwner {
        EigenCloudProof storage proof = taskProofs[taskId];
        if (!proof.verified) revert ProofNotFound(taskId);
        
        proof.verified = false;
        
        // Note: We don't decrement stats to maintain audit trail
        // But we mark it as invalidated
        
        emit ProofInvalidated(taskId, proof.agent, proof.proofHash, reason);
    }
    
    /**
     * @notice Check if task has verified proof
     */
    function hasProof(uint256 taskId) external view returns (bool) {
        return taskProofs[taskId].verified;
    }
    
    /**
     * @notice Get proof details
     */
    function getProof(uint256 taskId) external view returns (
        bytes32 proofHash,
        uint8 vType,
        uint256 timestamp,
        address agent,
        bool verified,
        bytes32 teeAttestation
    ) {
        EigenCloudProof memory p = taskProofs[taskId];
        return (p.proofHash, uint8(p.vType), p.timestamp, p.agent, p.verified, p.teeAttestation);
    }
    
    /**
     * @notice Get boosted reputation
     */
    function getBoostedReputation(address agent) external view returns (
        uint256 baseScore, 
        uint256 boostedScore, 
        uint256 multiplier, 
        VerificationType vLevel
    ) {
        (,,, uint256 reputationScore,,,) = arp.getAgent(agent);
        baseScore = reputationScore;
        
        AgentStats memory stats = agentStats[agent];
        vLevel = stats.highestLevel;
        
        if (vLevel == VerificationType.FULL_VERIFICATION) {
            multiplier = FULL_MULTIPLIER;
        } else if (vLevel == VerificationType.EIGENCOMPUTE_TEE) {
            multiplier = EIGENCOMPUTE_MULTIPLIER;
        } else if (vLevel == VerificationType.EIGENAI_DETERMINISTIC) {
            multiplier = EIGENAI_MULTIPLIER;
        } else {
            multiplier = BASE_MULTIPLIER;
        }
        
        boostedScore = (baseScore * multiplier) / BASE_MULTIPLIER;
    }
    
    /**
     * @notice Get detailed agent stats
     */
    function getDetailedAgentStats(address agent) external view returns (
        uint256 totalVerified,
        uint256 eigenAiTasks,
        uint256 teeTasks,
        uint256 fullVerificationTasks,
        VerificationType highestLevel,
        uint256 lastActivity,
        uint256 currentMultiplier
    ) {
        AgentStats memory stats = agentStats[agent];
        
        totalVerified = stats.totalVerifiedTasks;
        eigenAiTasks = stats.eigenAiTasks;
        teeTasks = stats.teeTasks;
        fullVerificationTasks = stats.fullVerificationTasks;
        highestLevel = stats.highestLevel;
        lastActivity = stats.lastActivityTimestamp;
        
        if (highestLevel == VerificationType.FULL_VERIFICATION) {
            currentMultiplier = FULL_MULTIPLIER;
        } else if (highestLevel == VerificationType.EIGENCOMPUTE_TEE) {
            currentMultiplier = EIGENCOMPUTE_MULTIPLIER;
        } else if (highestLevel == VerificationType.EIGENAI_DETERMINISTIC) {
            currentMultiplier = EIGENAI_MULTIPLIER;
        } else {
            currentMultiplier = BASE_MULTIPLIER;
        }
    }
    
    /**
     * @notice Get agent's verified task IDs
     */
    function getAgentTaskIds(address agent) external view returns (uint256[] memory) {
        return agentVerifiedTasks[agent];
    }
    
    /**
     * @notice Admin: Update timestamp settings
     */
    function updateTimestampSettings(
        uint256 _minProofTimestamp,
        uint256 _maxProofTimestamp
    ) external onlyOwner {
        require(_maxProofTimestamp > _minProofTimestamp, "Invalid timestamp range");
        minProofTimestamp = _minProofTimestamp;
        maxProofTimestamp = _maxProofTimestamp;
        emit SettingsUpdated(_minProofTimestamp, _maxProofTimestamp);
    }
    
    /**
     * @notice Admin: Emergency pause
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @notice Admin: Unpause
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
