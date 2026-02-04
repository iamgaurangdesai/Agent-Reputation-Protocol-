// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title AgentReputationProtocol
 * @dev On-chain reputation system for AI agents with Ethos integration
 * 
 * Features:
 * - Agent registration with stake
 * - Transaction attestations with ratings
 * - Unified score: 50% ARP + 50% Ethos credibility
 * - Shared slashing with Ethos network
 * - Delegated staking
 */
contract AgentReputationProtocol is Ownable, ReentrancyGuard {
    
    // Constants
    uint256 public constant ARP_WEIGHT = 50;
    uint256 public constant ETHOS_WEIGHT = 50;
    uint256 public constant MAX_SLASH_PERCENTAGE = 50;
    uint256 public constant MIN_STAKE = 10 ether;
    
    // Tier thresholds
    uint256 public constant TIER_LEGENDARY = 100;
    uint256 public constant TIER_ELITE = 75;
    uint256 public constant TIER_ESTABLISHED = 50;
    uint256 public constant TIER_TRUSTED = 25;
    
    // Storage
    mapping(address => Agent) public agents;
    mapping(bytes32 => Transaction) public transactions;
    mapping(address => address[]) public delegators;
    mapping(address => uint256) public ethosScores; // Integrated Ethos credibility
    
    uint256 public totalAgents;
    address[] public agentList;
    
    // Events
    event AgentRegistered(address indexed agent, string name, uint256 stake);
    event TransactionRecorded(bytes32 indexed txHash, address indexed from, address indexed to, uint256 amount);
    event AttestationSubmitted(bytes32 indexed txHash, address indexed attestor, uint8 rating, string feedback);
    event StakeDelegated(address indexed delegator, address indexed agent, uint256 amount);
    event AgentSlashed(address indexed agent, uint256 amount, string reason);
    event ScoreUpdated(address indexed agent, uint256 newScore, string newTier);
    
    struct Agent {
        string name;
        address wallet;
        uint256 stake;
        uint256 delegatedStake;
        uint256 arpScore;
        uint256 arpRatingsCount;
        uint256 arpTotalRating;
        uint256 walletAge; // in seconds
        uint256 lastActive;
        bool exists;
        string tier;
        uint256 riskScore;
    }
    
    struct Transaction {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
        bool attested;
        int8 finalRating; // -5 to 5 scale
    }
    
    constructor() {
        _initializeAgents();
    }
    
    function _initializeAgents() internal {
        // Pre-register demo agents
        _registerDemoAgent("Gaurang-Desai", 0xGAURANGDESAIHACK000000000000000000000, 500 ether, 190, 144, 2);
        _registerDemoAgent("Trustworthy-Alice", 0xTRUSTWORTHYALICE0000000000000000000, 200 ether, 112, 145, 2);
        _registerDemoAgent("ScamBot-Eve", 0xSCAMBOTEVE000000000000000000000000, 5 ether, 11, 0, 90, true);
    }
    
    function _registerDemoAgent(string memory name, address wallet, uint256 stake, uint256 arpScore, uint256 ethosScore, uint256 riskScore) internal {
        require(!agents[wallet].exists, "Agent exists");
        agents[wallet] = Agent({
            name: name,
            wallet: wallet,
            stake: stake,
            delegatedStake: 0,
            arpScore: arpScore,
            arpRatingsCount: 1,
            arpTotalRating: arpScore,
            walletAge: block.timestamp,
            lastActive: block.timestamp,
            exists: true,
            tier: _calculateTier(arpScore, ethosScore),
            riskScore: riskScore
        });
        ethosScores[wallet] = ethosScore;
        agentList.push(wallet);
        totalAgents++;
    }
    
    /**
     * @dev Register a new agent
     */
    function registerAgent(string memory name, uint256 stake) external nonReentrant {
        require(stake >= MIN_STAKE, "Stake too low");
        require(!agents[msg.sender].exists, "Agent exists");
        
        agents[msg.sender] = Agent({
            name: name,
            wallet: msg.sender,
            stake: stake,
            delegatedStake: 0,
            arpScore: 0,
            arpRatingsCount: 0,
            arpTotalRating: 0,
            walletAge: block.timestamp,
            lastActive: block.timestamp,
            exists: true,
            tier: "Newcomer",
            riskScore: 50 // Default medium risk
        });
        
        agentList.push(msg.sender);
        totalAgents++;
        
        emit AgentRegistered(msg.sender, name, stake);
    }
    
    /**
     * @dev Record a transaction
     */
    function recordTransaction(address to, uint256 amount) external returns (bytes32) {
        require(agents[msg.sender].exists, "Sender not registered");
        require(agents[to].exists, "Recipient not registered");
        
        bytes32 txHash = keccak256(abi.encodePacked(msg.sender, to, amount, block.timestamp));
        
        transactions[txHash] = Transaction({
            from: msg.sender,
            to: to,
            amount: amount,
            timestamp: block.timestamp,
            attested: false,
            finalRating: 0
        });
        
        agents[msg.sender].lastActive = block.timestamp;
        agents[to].lastActive = block.timestamp;
        
        emit TransactionRecorded(txHash, msg.sender, to, amount);
        
        return txHash;
    }
    
    /**
     * @dev Submit attestation for a transaction
     */
    function attestTransaction(
        bytes32 txHash,
        int8 rating, // -5 to 5
        string memory feedback
    ) external nonReentrant {
        require(transactions[txHash].timestamp != 0, "Tx not found");
        require(!transactions[txHash].attested, "Already attested");
        require(rating >= -5 && rating <= 5, "Invalid rating");
        
        Transaction storage tx = transactions[txHash];
        address attestor = msg.sender;
        
        // Update agent scores
        Agent storage toAgent = agents[tx.to];
        toAgent.arpRatingsCount++;
        toAgent.arpTotalRating += uint8(rating >= 0 ? rating : 0);
        
        // Update ARP score
        uint256 avgRating = toAgent.arpTotalRating / toAgent.arpRatingsCount;
        toAgent.arpScore = (avgRating * 20) + (toAgent.stake / 1 ether) + (toAgent.arpRatingsCount * 2);
        
        tx.attested = true;
        tx.finalRating = rating;
        
        _updateUnifiedScore(tx.to);
        
        emit AttestationSubmitted(txHash, attestor, uint8(rating + 5), feedback);
    }
    
    /**
     * @dev Delegate stake to an agent
     */
    function delegateStake(address agent, uint256 amount) external payable nonReentrant {
        require(agents[agent].exists, "Agent not found");
        require(msg.value >= MIN_STAKE, "Amount too low");
        
        agents[agent].delegatedStake += msg.value;
        delegators[agent].push(msg.sender);
        
        _updateUnifiedScore(agent);
        
        emit StakeDelegated(msg.sender, agent, msg.value);
    }
    
    /**
     * @dev Slash an agent (shared with Ethos)
     */
    function slashAgent(address agent, uint256 percentage, string memory reason) external onlyOwner nonReentrant {
        require(agents[agent].exists, "Agent not found");
        require(percentage <= MAX_SLASH_PERCENTAGE, "Percentage too high");
        
        uint256 slashAmount = (agents[agent].stake * percentage) / 100;
        agents[agent].stake -= slashAmount;
        agents[agent].arpScore = agents[agent].arpScore * (100 - percentage) / 100;
        agents[agent].riskScore = Math.min(100, agents[agent].riskScore + 20);
        
        _updateUnifiedScore(agent);
        
        emit AgentSlashed(agent, slashAmount, reason);
    }
    
    /**
     * @dev Update Ethos score (integration point)
     */
    function updateEthosScore(address agent, uint256 score) external onlyOwner {
        require(agents[agent].exists, "Agent not found");
        ethosScores[agent] = score;
        _updateUnifiedScore(agent);
    }
    
    /**
     * @dev Calculate unified score (50% ARP + 50% Ethos)
     */
    function _updateUnifiedScore(address agent) internal {
        Agent storage a = agents[agent];
        uint256 arpNormalized = Math.min(a.arpScore / 2, 100);
        uint256 ethosNormalized = Math.min(ethosScores[agent], 100);
        
        uint256 unifiedScore = (arpNormalized * ARP_WEIGHT + ethosNormalized * ETHOS_WEIGHT) / 100;
        
        a.tier = _calculateTier(arpNormalized, ethosNormalized);
        a.riskScore = _calculateRisk(a);
        
        emit ScoreUpdated(agent, unifiedScore, a.tier);
    }
    
    function _calculateTier(uint256 arpScore, uint256 ethosScore) internal pure returns (string memory) {
        uint256 unified = (arpScore * 50 + ethosScore * 50) / 100;
        
        if (unified >= TIER_LEGENDARY) return "Legendary";
        if (unified >= TIER_ELITE) return "Elite";
        if (unified >= TIER_ESTABLISHED) return "Established";
        if (unified >= TIER_TRUSTED) return "Trusted";
        return "Newcomer";
    }
    
    function _calculateRisk(Agent storage a) internal view returns (uint256) {
        uint256 risk = 50;
        
        // Wallet age reduces risk
        uint256 ageInDays = (block.timestamp - a.walletAge) / 1 days;
        risk = risk > ageInDays ? risk - Math.min(ageInDays, 30) : 0;
        
        // High ratings reduce risk
        if (a.arpRatingsCount > 0) {
            uint256 avgRating = a.arpTotalRating / a.arpRatingsCount;
            risk = risk > avgRating * 2 ? risk - avgRating * 2 : 0;
        }
        
        // Negative attestations increase risk
        // In real implementation, track separately
        
        return Math.min(100, risk);
    }
    
    // View functions
    function getAgent(address wallet) external view returns (
        string memory name,
        uint256 stake,
        uint256 arpScore,
        uint256 ethosScore,
        uint256 unifiedScore,
        string memory tier,
        uint256 riskScore
    ) {
        Agent storage a = agents[wallet];
        uint256 arpNormalized = Math.min(a.arpScore / 2, 100);
        uint256 ethosNormalized = Math.min(ethosScores[wallet], 100);
        unifiedScore = (arpNormalized * 50 + ethosNormalized * 50) / 100;
        
        return (
            a.name,
            a.stake,
            a.arpScore,
            ethosScores[wallet],
            unifiedScore,
            a.tier,
            a.riskScore
        );
    }
    
    function getLeaderboard() external view returns (
        address[] memory,
        uint256[] memory,
        string[] memory
    ) {
        // Sort by unified score
        uint256[] memory scores = new uint256[](agentList.length);
        string[] memory tiers = new string[](agentList.length);
        
        for (uint256 i = 0; i < agentList.length; i++) {
            address wallet = agentList[i];
            Agent storage a = agents[wallet];
            uint256 arp = Math.min(a.arpScore / 2, 100);
            uint256 ethos = Math.min(ethosScores[wallet], 100);
            scores[i] = (arp * 50 + ethos * 50) / 100;
            tiers[i] = a.tier;
        }
        
        return (agentList, scores, tiers);
    }
}

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
