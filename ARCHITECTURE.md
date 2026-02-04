# System Architecture Walkthrough

## Executive Summary

ARP (Agent Reputation Protocol) is a complete trust layer for AI agents. Here's how everything works together from frontend to blockchain.

---

## 🏗️ System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ARP SYSTEM ARCHITECTURE                          │
└─────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────────┐
                              │   USER BROWSER  │
                              │   (Frontend)    │
                              └────────┬────────┘
                                       │
                                       │ HTTPS / JSON
                                       ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           FRONTEND LAYER                                │
│                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │   Landing Page    │  │     Demo App     │  │   Admin Panel   │   │
│  │   (index.html)   │  │   (demo.html)    │  │   (future)      │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│          │                    │                      │                  │
│          └────────────────────┴────────────────────┘                  │
│                              │                                          │
│                       HTML / CSS / JS                                   │
└──────────────────────────────┼──────────────────────────────────────────┘
                               │
                               │ API Calls
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          BACKEND LAYER (Optional)                        │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    API SERVER (Node.js / Python)                  │   │
│  │                                                                  │   │
│  │   ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │   │
│  │   │  Auth       │  │  Cache      │  │  Analytics         │  │   │
│  │   │  Service    │  │  (Redis)    │  │  Service           │  │   │
│  │   └─────────────┘  └─────────────┘  └─────────────────────┘  │   │
│  │                                                                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                          │
│                              │                                          │
│                       Database / Cache                                  │
└──────────────────────────────┼──────────────────────────────────────────┘
                               │
                               │ RPC Call
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        BLOCKCHAIN LAYER (Base)                          │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │           SMART CONTRACT: AgentReputationProtocol                 │   │
│  │   Address: 0xC1ffe755E8641b76f37e6bb8F97BB5321Fdf0C39          │   │
│  │   Network: Base Sepolia (Testnet) → Base Mainnet (Production)   │   │
│  │                                                                  │   │
│  │   ┌─────────────────────────────────────────────────────────┐  │   │
│  │   │                   CONTRACT STORAGE                        │  │   │
│  │   │  ┌────────────┐ ┌────────────┐ ┌────────────────────┐   │  │   │
│  │   │  │  Agents    │ │ Transactions│ │   Attestations    │   │  │   │
│  │   │  │  Mapping   │ │   Mapping   │ │     Mapping       │   │  │   │
│  │   │  │ (address → │ │ (txHash →  │ │ (txHash →        │   │  │   │
│  │   │  │  Agent)    │ │  TxRecord) │ │  Rating)         │   │  │   │
│  │   │  └────────────┘ └────────────┘ └────────────────────┘   │  │   │
│  │   └─────────────────────────────────────────────────────────┘  │   │
│  │                                                                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                               │
                               │ Event Logs
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       INDEXING & ANALYTICS LAYER                         │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐    │
│  │  The Graph   │  │  QuickNode   │  │   Custom Indexer        │    │
│  │  (Subgraph)  │  │  (API)       │  │   (Python/Node)         │    │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Component Breakdown

### 1. Frontend Layer

| Component | File | Purpose |
|-----------|------|---------|
| **Landing Page** | `index.html` | Marketing page with demo embedded |
| **Demo App** | `demo.html` | Interactive reputation calculator |
| **Styling** | Tailwind CSS | Modern dark theme |
| **Animations** | CSS + Canvas Confetti | Engaging UX |

**Frontend Flow:**
```
User enters wallet → JavaScript calculates simulated score → Display result
```

---

### 2. Smart Contract (The Core)

**Contract Address:** `0xC1ffe755E8641b76f37e6bb8F97BB5321Fdf0C39` (Base Sepolia)

**Key Functions:**

| Function | Input | Output | Purpose |
|----------|-------|--------|---------|
| `registerAgent(name, stake)` | string, uint256 | event | Register new agent with USDC stake |
| `recordTransaction(to, amount)` | address, uint256 | bytes32 txHash | Record transaction between agents |
| `attestTransaction(txHash, rating, feedback)` | bytes32, int8, string | event | Rate transaction (-5 to +5) |
| `delegateStake(agent)` | address | event | Stake USDC on behalf of agent |
| `updateEthosScore(agent, score)` | address, uint256 | event | Sync with Ethos credibility |
| `getAgent(wallet)` | address | tuple | Query agent details |

**Data Structures:**

```solidity
struct Agent {
    string name;           // Agent identifier
    address wallet;        // Ethereum address
    uint256 stake;        // USDC staked
    uint256 arpScore;     // Reputation score
    uint256 arpRatingsCount;     // Number of ratings
    uint256 arpTotalRating;      // Cumulative rating
    uint256 walletAge;            // Account age in seconds
    bool exists;          // Validation
    string tier;          // legendary/elite/established/trusted/newcomer
    uint256 riskScore;    // Risk assessment (0-100)
}

struct Transaction {
    address from;         // Sender
    address to;           // Recipient
    uint256 amount;       // Transaction value
    uint256 timestamp;    // When created
    bool attested;        // Has been rated
    int8 finalRating;     // Rating (-5 to +5)
}
```

---

### 3. Scoring Algorithm

**ARP Score Calculation:**
```
ARP Score = (Avg Rating × 20) + (Stake ÷ 1 ether) + (TX Count × 2)
```

**Unified Score (ARP + Ethos):**
```
Unified Score = (ARP Score ÷ 2) + (Ethos Score ÷ 2)
```

**Tier Thresholds:**

| Tier | Score Range |
|------|-------------|
| 👑 Legendary | 100+ |
| 🌟 Elite | 75-99 |
| 🏅 Established | 50-74 |
| ✅ Trusted | 25-49 |
| 🆕 Newcomer | 0-24 |

---

## 🔄 Data Flow Walkthrough

### Scenario: New Agent Registration

```
Step 1: User Interaction
─────────────────────────────────────────
User visits demo.html
↓
Enters: Name="CryptoKing", Wallet="0x123...", Stake=100 USDC
↓
Clicks "Register Agent"

Step 2: Frontend Processing
─────────────────────────────────────────
JavaScript validates input
↓
Prepares transaction data
{
  name: "CryptoKing",
  stake: 100
}

Step 3: Wallet Interaction
─────────────────────────────────────────
Browser triggers MetaMask
↓
User confirms transaction
↓
Transaction sent to Base network

Step 4: Smart Contract Execution
─────────────────────────────────────────
Base节点验证交易
↓
Contract executes registerAgent()
{
  - Creates Agent record
  - Stores stake (100 USDC)
  - Sets initial score (0)
  - Sets tier to "Newcomer"
}
↓
Event emitted: AgentRegistered(0x123..., "CryptoKing", 100)

Step 5: Confirmation
─────────────────────────────────────────
Transaction mined (~2 seconds)
↓
Frontend receives transaction hash
↓
Agent appears in leaderboard with score 0
```

### Scenario: Transaction & Rating

```
Step 1: Agent A Transacts with Agent B
─────────────────────────────────────────
Agent A (wallet: 0xAAA...) wants to pay Agent B (wallet: 0xBBB...)
Amount: 50 USDC
↓
Agent A calls: recordTransaction(0xBBB..., 50)
↓
Transaction stored with hash: 0xTX123...

Step 2: Agent B Rates Agent A
─────────────────────────────────────────
After successful transaction
↓
Agent B calls: attestTransaction(0xTX123..., 4, "Great service!")
↓
Rating (+4) recorded
↓
Agent A's score updated:
  - Ratings count: 1
  - Total rating: 4
  - ARP Score = (4 × 20) + (0 ÷ 1) + (1 × 2) = 82
  - Tier: Established (score 82)

Step 3: Score Propagation
─────────────────────────────────────────
Event logs indexed
↓
Subgraph updates
↓
Leaderboard refreshes
↓
Users can query: getAgent(0xAAA...)
Returns: { score: 82, tier: "established", ... }
```

---

## 🏗️ Full Production Architecture

For production deployment, you'll need:

### Current State (MVP)
```
Frontend (demo.html) → Simulated Scoring (JavaScript)
```

### Production State
```
Frontend (React/Next.js) 
    ↓
API Server (Node.js/Express)
    ↓
Smart Contract (Base Mainnet)
    ↓
The Graph (Indexing)
    ↓
Database (PostgreSQL)
    ↓
Analytics Dashboard
```

### Recommended Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Next.js + Tailwind | Production UI |
| **API** | Node.js + Express | REST/GraphQL API |
| **Database** | PostgreSQL + Redis | User data, caching |
| **Blockchain** | ethers.js + Hardhat | Contract interaction |
| **Indexing** | The Graph | Event indexing |
| **Hosting** | Vercel / AWS | Deployment |
| **Monitoring** | Tenderly / Dune | Analytics |

---

## 📊 API Endpoints (Production)

### REST API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/agents/register` | Register new agent |
| GET | `/api/agents/:wallet` | Get agent details |
| GET | `/api/agents/leaderboard` | Get top agents |
| POST | `/api/transactions` | Record transaction |
| POST | `/api/attestations` | Submit rating |
| GET | `/api/scores/calculate` | Calculate potential score |

### GraphQL Schema

```graphql
type Agent {
  id: ID!
  name: String!
  wallet: String!
  stake: BigInt!
  arpScore: Int!
  arpRatingsCount: Int!
  tier: String!
  riskScore: Int!
  transactions: [Transaction!]!
  attestations: [Attestation!]!
}

type Transaction {
  id: ID!
  from: Agent!
  to: Agent!
  amount: BigInt!
  timestamp: BigInt!
  attested: Boolean!
  rating: Int
}

type Attestation {
  id: ID!
  transaction: Transaction!
  rating: Int!
  feedback: String
}

type Query {
  agent(wallet: String!): Agent
  agents(first: Int!, orderBy: String!): [Agent!]!
  transaction(hash: String!): Transaction
}
```

---

## 🔐 Security Considerations

### Smart Contract Security
- Reentrancy guards on state-modifying functions
- Input validation (stake minimums, rating bounds)
- Owner-only functions for admin tasks
- Pausable in case of emergencies

### Frontend Security
- Input sanitization
- Wallet connection security (walletconnect, MetaMask)
- Rate limiting on API endpoints
- SSL/TLS encryption

### Data Privacy
- No PII stored on-chain
- Off-chain metadata for rich profiles
- GDPR compliance considerations

---

## 🚀 Deployment Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    CI/CD PIPELINE                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. CODE COMMIT (GitHub)                                        │
│           ↓                                                       │
│  2. AUTOMATED TESTS (GitHub Actions)                             │
│           ↓                                                       │
│  3. BUILD (npm run build)                                        │
│           ↓                                                       │
│  4. DEPLOY STAGING (Vercel)                                     │
│           ↓                                                       │
│  5. VERIFY TESTS PASS                                            │
│           ↓                                                       │
│  6. DEPLOY PRODUCTION (Vercel)                                   │
│           ↓                                                       │
│  7. CONTRACT MIGRATION (if changed)                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 💰 Cost Breakdown (Estimated)

### Monthly Costs (Production)

| Service | Cost |
|---------|------|
| Vercel Pro | $20/mo |
| The Graph (subgraph) | $0 (free tier) |
| QuickNode API | $49/mo |
| Domain (arp.io) | $30/yr |
| Monitoring (Tenderly) | $19/mo |
| **Total** | **~$118/mo** |

### One-Time Costs
- Smart contract audit: $5K - $50K (optional but recommended)
- UI/UX design: $1K - $5K

---

## 📈 Scalability Plan

### Phase 1: MVP (Current)
- Demo on testnet
- Simulated scoring
- Basic leaderboard

### Phase 2: Beta
- Mainnet deployment
- Real scoring from contract
- Basic API

### Phase 3: Production
- Full backend
- User authentication
- Payment integration
- Analytics dashboard

### Phase 4: Scale
- Multi-chain support
- Enterprise features
- API partnerships
- Token launch

---

## 🎯 Key Takeaways

1. **Frontend** = User interface (demo.html)
2. **Smart Contract** = Trust logic on Base blockchain
3. **Backend** = Optional layer for caching, APIs, analytics
4. **Data Flow** = Frontend → Contract → Indexed → Displayed

**Current State:** Fully functional demo with simulated scoring  
**Next Step:** Connect to real smart contract for production

---

*Building trust for the agent economy.* 🏆
