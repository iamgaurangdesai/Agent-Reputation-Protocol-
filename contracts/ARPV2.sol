// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title AgentReputationProtocol
 * @dev On-chain reputation system for AI agents - USDC Staking Edition
 * 
 * Features:
 * - USDC staking ($1 min, $10 max)
 * - Transaction attestations with ratings
 * - Unified score: 50% ARP + 50% Ethos credibility
 */
contract AgentReputationProtocol is Ownable, ReentrancyGuard {
    
    IERC20 public immutable usdc;
    
    uint256 public constant MIN_STAKE_USDC = 1 * 10**6;   // $1
    uint256 public constant MAX_STAKE_USDC = 10 * 10**6;  // $10
    uint256 public constant ARP_WEIGHT = 50;
    uint256 public constant ETHOS_WEIGHT = 50;
    
    mapping(address => Agent) public agents;
    mapping(bytes32 => Txn) public transactions;
    mapping(address => uint256) public ethosScores;
    
    address[] public agentList;
    
    struct Agent {
        string name;
        address wallet;
        uint256 stake;
        uint256 arpScore;
        uint256 arpRatingsCount;
        uint256 arpTotalRating;
        uint256 walletAge;
        uint256 lastActive;
        bool exists;
        string tier;
        uint256 riskScore;
    }
    
    struct Txn {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
        bool attested;
        int8 finalRating;
    }
    
    event AgentRegistered(address indexed agent, string name, uint256 usdcStake);
    event AttestationSubmitted(bytes32 indexed txHash, address indexed attestor, uint8 rating);
    event ScoreUpdated(address indexed agent, uint256 newScore, string newTier);
    
    constructor(address _usdc, address _owner) Ownable(_owner) {
        usdc = IERC20(_usdc);
    }
    
    function registerAgent(string memory name, uint256 stakeUsdc) external nonReentrant {
        require(stakeUsdc >= MIN_STAKE_USDC, "Min $1 USDC");
        require(stakeUsdc <= MAX_STAKE_USDC, "Max $10 USDC");
        require(!agents[msg.sender].exists, "Already registered");
        
        require(usdc.transferFrom(msg.sender, address(this), stakeUsdc), "USDC transfer failed");
        
        agents[msg.sender] = Agent({
            name: name,
            wallet: msg.sender,
            stake: stakeUsdc,
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
        emit AgentRegistered(msg.sender, name, stakeUsdc);
    }
    
    function attestTransaction(bytes32 txHash, int8 rating) external nonReentrant {
        require(transactions[txHash].timestamp != 0, "Tx not found");
        require(!transactions[txHash].attested, "Already attested");
        require(rating >= -5 && rating <= 5, "Rating -5 to 5");
        
        Txn storage t = transactions[txHash];
        Agent storage toAgent = agents[t.to];
        
        toAgent.arpRatingsCount++;
        if (rating > 0) {
            toAgent.arpTotalRating += uint256(int256(rating));
        }
        
        uint256 avgRating = toAgent.arpTotalRating / toAgent.arpRatingsCount;
        uint256 stakeBonus = toAgent.stake / (1 * 10**6);
        toAgent.arpScore = (avgRating * 20) + stakeBonus + (toAgent.arpRatingsCount * 2);
        
        t.attested = true;
        t.finalRating = rating;
        
        _updateScore(t.to);
        emit AttestationSubmitted(txHash, msg.sender, uint8(rating + 5));
    }
    
    function _updateScore(address agentAddr) internal {
        Agent storage a = agents[agentAddr];
        uint256 arpNorm = min(a.arpScore / 2, 100);
        uint256 ethosNorm = min(ethosScores[agentAddr], 100);
        uint256 unified = (arpNorm * ARP_WEIGHT + ethosNorm * ETHOS_WEIGHT) / 100;
        
        a.tier = _getTier(unified);
        emit ScoreUpdated(agentAddr, unified, a.tier);
    }
    
    function _getTier(uint256 score) internal pure returns (string memory) {
        if (score >= 100) return "Legendary";
        if (score >= 75) return "Elite";
        if (score >= 50) return "Established";
        if (score >= 25) return "Trusted";
        return "Newcomer";
    }
    
    function updateEthosScore(address agentAddr, uint256 score) external onlyOwner {
        require(agents[agentAddr].exists, "Not found");
        ethosScores[agentAddr] = score;
        _updateScore(agentAddr);
    }
    
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
        uint256 arpNorm = min(a.arpScore / 2, 100);
        uint256 ethosNorm = min(ethosScores[wallet], 100);
        return (
            a.name,
            a.stake,
            a.arpScore,
            ethosScores[wallet],
            (arpNorm * 50 + ethosNorm * 50) / 100,
            a.tier,
            a.riskScore
        );
    }
    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}