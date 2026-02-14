// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AgentReputationProtocol - Simplified for Testing
 * @dev Minimal version for Sepolia testing
 */
contract AgentReputationProtocol {
    
    struct Agent {
        string name;
        string bio;
        string[] skills;
        uint256 reputationScore;
        uint256 tasksCompleted;
        uint256 stakeAmount;
        bool isRegistered;
    }
    
    struct Task {
        string description;
        uint256 reward;
        address creator;
        address agent;
        bool isCompleted;
        bool isDisputed;
    }
    
    mapping(address => Agent) public agents;
    mapping(uint256 => Task) public tasks;
    mapping(address => uint256[]) public agentTasks;
    
    uint256 public totalAgents;
    uint256 public totalTasks;
    uint256 public registrationFee = 0.001 ether;
    
    event AgentRegistered(address indexed agent, string name, uint256 stake);
    event TaskCreated(uint256 indexed taskId, string description, uint256 reward);
    event TaskCompleted(uint256 indexed taskId, address indexed agent, string solution);
    
    function registerAgent(string memory name, string memory bio, string[] memory skills) external payable {
        require(!agents[msg.sender].isRegistered, "Already registered");
        require(msg.value >= registrationFee, "Insufficient fee");
        
        agents[msg.sender] = Agent({
            name: name,
            bio: bio,
            skills: skills,
            reputationScore: 100,
            tasksCompleted: 0,
            stakeAmount: msg.value,
            isRegistered: true
        });
        
        totalAgents++;
        emit AgentRegistered(msg.sender, name, msg.value);
    }
    
    function createTask(string memory description) external payable {
        uint256 taskId = totalTasks++;
        tasks[taskId] = Task({
            description: description,
            reward: msg.value,
            creator: msg.sender,
            agent: address(0),
            isCompleted: false,
            isDisputed: false
        });
        emit TaskCreated(taskId, description, msg.value);
    }
    
    function completeTask(uint256 taskId, string memory solution) external {
        require(agents[msg.sender].isRegistered, "Not registered");
        Task storage task = tasks[taskId];
        require(!task.isCompleted, "Already completed");
        require(task.reward > 0, "Task not found");
        
        task.agent = msg.sender;
        task.isCompleted = true;
        agents[msg.sender].tasksCompleted++;
        agents[msg.sender].reputationScore += 10;
        
        // Transfer reward
        payable(msg.sender).transfer(task.reward);
        
        emit TaskCompleted(taskId, msg.sender, solution);
    }
    
    function getAgent(address agentAddress) external view returns (
        string memory name,
        string memory bio,
        string[] memory skills,
        uint256 reputationScore,
        uint256 tasksCompleted,
        uint256 stakeAmount,
        bool isRegistered
    ) {
        Agent storage a = agents[agentAddress];
        return (a.name, a.bio, a.skills, a.reputationScore, a.tasksCompleted, a.stakeAmount, a.isRegistered);
    }
    
    function getTask(uint256 taskId) external view returns (
        string memory description,
        uint256 reward,
        address creator,
        address agent,
        bool isCompleted,
        bool isDisputed
    ) {
        Task storage t = tasks[taskId];
        return (t.description, t.reward, t.creator, t.agent, t.isCompleted, t.isDisputed);
    }
}
