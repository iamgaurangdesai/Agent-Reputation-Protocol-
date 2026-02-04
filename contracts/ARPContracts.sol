// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IAgentRegistry
 * @notice Interface for agent registration in the ARP protocol
 */
interface IAgentRegistry {
    struct Agent {
        address id;
        string name;
        uint256 stakedUSDC;
        uint256 reputationScore;
        bool exists;
    }
    
    function registerAgent(string memory name, uint256 stakeAmount) external returns (address);
    function getAgent(address agentId) external view returns (Agent memory);
    function updateReputation(address agentId, int256 delta) external;
    function slashAgent(address agentId, uint256 amount) external;
}

/**
 * @title IAttestation
 * @notice Interface for transaction attestations
 */
interface IAttestation {
    struct Attestation {
        address fromAgent;
        address toAgent;
        bytes32 transactionHash;
        uint8 rating;  // 1-5
        string feedback;
        uint256 timestamp;
        AttestationType attestationType;
    }
    
    enum AttestationType {
        COMPLETED,
        PARTIAL,
        FAILED,
        UNKNOWN
    }
    
    function submitAttestation(
        address toAgent,
        bytes32 transactionHash,
        uint8 rating,
        string memory feedback,
        AttestationType attestationType
    ) external;
    
    function getAttestationsForAgent(address agentId) external view returns (Attestation[] memory);
}

/**
 * @title AgentReputationProtocol
 * @notice Main contract for the Agent Reputation Protocol
 * @dev This is a placeholder for the actual implementation
 */
contract AgentReputationProtocol {
    // Placeholder for ARP contract implementation
    // Full implementation coming in v2.0
}
