// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title AgentReputationProtocol v2
 * @dev On-chain reputation system for AI agents - USDC Staking Edition
 * 
 * Updates:
 * - USDC staking instead of ETH (min $1, max $10)
 * - More accessible for hackathon testing
 */
contract AgentReputationProtocol is Ownable, ReentrancyGuard {
    
    // USDC Token (Base Sepolia)
    IERC20 public immutable usdc;
    uint256 public constant USDC_DECIMALS = 6;
    
    // Stake limits in USDC ($1 - $10)
    uint256 public constant MIN_STAKE_USDC = 1 * 10**6;      // $1 USDC
    uint256 public constant MAX_STAKE_USDC = 10 * 10**6;     // $10 USDC
    
    // Scoring weights
    uint256 public constant ARP_WEIGHT = 50;
    uint256 public constant ETHOS_WEIGHT = 50;
    uint256 public constant MAX_SLASH_PERCENTAGE = 50;
    
    // Tier thresholds
    uint256 public constant TIER_LEGENDARY = 100;
    uint256 public constant TIER_ELITE = 75;
    uint256 public constant TIER_ESTABLISHED = 50;
    uint256 public constant TIER_TRUSTED = 25;
    
    // Storage
    mapping(address => Agent) public agents;
    mapping(bytes32 => Transaction) public transactions;
    mapping(address => address[]) public delegators;
    mapping(address => uint256) public ethosScores;
    
    uint256 public totalAgents;
    address[] public agentList;
    
    // Events
    event AgentRegistered(address indexed agent, string name, uint256 usdcStake);
    event TransactionRecorded(bytes32 indexed txHash, address indexed from, address indexed to, uint256 amount);
    event AttestationSubmitted(bytes32 indexed txHash, address indexed attestor, uint8 rating, string feedback);
    event StakeDelegated(address indexed delegator, address indexed agent, uint256 amount);
    event AgentSlashed(address indexed agent, uint256 amount, string reason);
    event ScoreUpdated(address indexed agent, uint256 newScore, string newTier);
    event StakeIncreased(address indexed agent, uint256 newStake);
    event StakeWithdrawn(address indexed agent, uint256 amount);
    
    struct Agent {
        string name;
        address wallet;
        uint256 stake; // in USDC (6 decimals)
        uint256 delegatedStake;
        uint256 arpScore;
        uint256 arpRatingsCount;
        uint256 arpTotalRating;
        uint256 walletAge;
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
        int8 finalRating;
    }
    
    constructor(address _usdcAddress, address _initialOwner) Ownable(_initialOwner) {
        usdc = IERC20(_usdcAddress);
        _initializeAgents();
    }
    
    function _initializeAgents() internal {
        // Pre-register demo agents with realistic USDC stakes
        _registerDemoAgent("Gaurang-Desai", 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045, 5_000_000, 190, 144, 2);
        _registerDemoAgent("Trustworthy-Alice", 0x71C7656EC7ab88b098defB751B7401B5f6d8976F, 3_000_000, 112, 145, 2);
        _registerDemoAgent("ScamBot-Eve", 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199, 1_000_000, 11, 0, 90);
    }
    
    function _registerDemoAgent(string memory name, address wallet, uint256 stakeUsdc, uint256 arpScore, uint256 ethosScore, uint256 riskScore) internal {
        require(!agents[wallet].exists, "Agent exists");
        agents[wallet] = Agent({
            name: name,
            wallet: wallet,
            stake: stakeUsdc,
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
     * @dev Register a new agent with USDC stake
     * @param name Agent name
     * @param stakeUsdc Amount in USDC (1-10 USDC, 6 decimals)
     */
    function registerAgent(string memory name, uint256 stakeUsdc) external nonReentrant {
        require(stakeUsdc >= MIN_STAKE_USDC, "Stake too low (min $1 USDC)");
        require(stakeUsdc <= MAX_STAKE_USDC, "Stake too high (max $10 USDC)");
        require(!agents[msg.sender].exists, "Agent already registered");
        
        // Transfer USDC from user to contract
        require(usdc.transferFrom(msg.sender, address(this), stakeUsdc), "USDC transfer failed");
        
        agents[msg.sender] = Agent({
            name: name,
            wallet: msg.sender,
            stake: stakeUsdc,
            delegatedStake: 0,
            arpScore: 0,
            arpRatingsCount: 0,
            arpTotalRating: 0,
            walletAge: block.timestamp,
            lastActive: block.timestamp,
            exists: true,
            tier: "Newcomer",
            riskScore: 50
        });
        
        agentList.push(msg.sender);
        totalAgents++;
        
        emit AgentRegistered(msg.sender, name, stakeUsdc);
    }
    
    /**
     * @dev Increase stake (up to max $10)
     */
    function increaseStake(uint256 additionalUsdc) external nonReentrant {
        require(agents[msg.sender].exists, "Agent not registered");
        
        Agent storage agent = agents[msg.sender];
        uint256 newStake = agent.stake + additionalUsdc;
        require(newStake <= MAX_STAKE_USDC, "Would exceed max stake ($10)");
        
        require(usdc.transferFrom(msg.sender, address(this), additionalUsdc), "USDC transfer failed");
        agent.stake = newStake;
        
        emit StakeIncreased(msg.sender, newStake);
    }
    
    /**
     * @dev Withdraw stake (requires 7-day cooldown in production)
     */
    function withdrawStake(uint256 amountUsdc) external nonReentrant {
        require(agents[msg.sender].exists, "Agent not registered");
        
        Agent storage agent = agents[msg.sender];
        require(amountUsdc <= agent.stake, "Insufficient stake");
        require(agent.stake - amountUsdc >= MIN_STAKE_USDC || amountUsdc == agent.stake, "Must keep min stake");
        
        agent.stake -= amountUsdc;
        require(usdc.transfer(msg.sender, amountUsdc), "USDC transfer failed");
        
        _updateUnifiedScore(msg.sender);
        emit StakeWithdrawn(msg.sender, amountUsdc);
    }
    
    /**
     * @dev Record a transaction between agents
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
     * @dev Submit attestation with rating
     */
    function attestTransaction(
        bytes32 txHash,
        int8 rating,
        string memory feedback
    ) external nonReentrant {
        require(transactions[txHash].timestamp != 0, "Tx not found");
        require(!transactions[txHash].attested, "Already attested");
        require(rating >= -5 && rating <= 5, "Invalid rating (-5 to 5)");
        
        Transaction storage txn = transactions[txHash];
        Agent storage toAgent = agents[txn.to];
        
        toAgent.arpRatingsCount++;
        // Handle rating: only add positive ratings
        if (rating > 0) {
            toAgent.arpTotalRating += uint8(uint256(int256(rating)));
        }
        
        uint256 avgRating = toAgent.arpTotalRating / toAgent.arpRatingsCount;
        // Score formula: ratings * 20 + stake_bonus + activity_bonus
        uint256 stakeBonus = toAgent.stake / (1 * 10**6); // 1 point per USDC
        toAgent.arpScore = (avgRating * 20) + stakeBonus + (toAgent.arpRatingsCount * 2);
        
        txn.attested = true;
        txn.finalRating = rating;
        
        _updateUnifiedScore(tx.to);
        
        emit AttestationSubmitted(txHash, msg.sender, uint8(rating + 5), feedback);
    }
    
    /**
     * @dev Update Ethos score (owner only)
     */
    function updateEthosScore(address agent, uint256 score) external onlyOwner {
        require(agents[agent].exists, "Agent not found");
        ethosScores[agent] = score;
        _updateUnifiedScore(agent);
    }
    
    /**
     * @dev Calculate unified score
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
        
        uint256 ageInDays = (block.timestamp - a.walletAge) / 1 days;
        risk = risk > ageInDays ? risk - Math.min(ageInDays, 30) : 0;
        
        if (a.arpRatingsCount > 0) {
            uint256 avgRating = a.arpTotalRating / a.arpRatingsCount;
            risk = risk > avgRating * 2 ? risk - avgRating * 2 : 0;
        }
        
        return Math.min(100, risk);
    }
    
    // View functions
    function getAgent(address wallet) external view returns (
        string memory name,
        uint256 stakeUsdc,
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
        address[] memory wallets,
        uint256[] memory scores,
        string[] memory tiers
    ) {
        uint256 count = agentList.length;
        wallets = new address[](count);
        scores = new uint256[](count);
        tiers = new string[](count);
        
        for (uint256 i = 0; i < count; i++) {
            address wallet = agentList[i];
            Agent storage a = agents[wallet];
            uint256 arp = Math.min(a.arpScore / 2, 100);
            uint256 ethos = Math.min(ethosScores[wallet], 100);
            
            wallets[i] = wallet;
            scores[i] = (arp * 50 + ethos * 50) / 100;
            tiers[i] = a.tier;
        }
        
        return (wallets, scores, tiers);
    }
    
    function getStakeLimits() external pure returns (uint256 min, uint256 max) {
        return (MIN_STAKE_USDC, MAX_STAKE_USDC);
    }
}

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}