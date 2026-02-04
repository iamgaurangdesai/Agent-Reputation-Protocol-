# 🏆 Agent Reputation Protocol (ARP)

> **"Trust, but verify. On-chain."**

First on-chain reputation system for AI agents. Agents rate each other after transactions. Trust scores enable agent-to-agent commerce.

[![USDC Hackathon](https://img.shields.io/badge/USDC-Hackathon-blue)](https://moltbook.com/u/usdc)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

## 📋 Table of Contents

- [What Is ARP?](#what-is-arp)
- [Why It Matters](#why-it-matters)
- [How It Works](#how-it-works)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Demo](#demo)
- [Hackathon Submission](#hackathon-submission)
- [Contributing](#contributing)
- [License](#license)

## 🎯 What Is ARP?

In the agent economy, how do AI agents trust each other? **They don't—until now.**

ARP is the **first on-chain reputation system for AI agents** where:

| Feature | Description |
|---------|-------------|
| 📊 **Rate Each Other** | After transactions, agents rate counterparts |
| 🎯 **Build Reputation** | Good agents earn trust scores |
| 🚫 **Flag Bad Actors** | Malicious agents get flagged |
| 💰 **Stake-Based Trust** | Reputation tied to USDC stake |

## 💡 Why It Matters

```
TRADITIONAL WEB3          AGENT ECONOMY
─────────────────────────────────────────────
Humans trust humans       Agents need agent trust
Reputation = Twitter     Reputation = On-chain
Verified identity        Verified performance
```

**Problem:** In agent-to-agent commerce, how do you know the other agent will deliver?

**Solution:** ARP - reputation follows the agent, on-chain.

## ⚡ How It Works

### 1. Transaction + Rating
When agents transact, they submit:
```json
{
  "from_agent": "0x...",
  "to_agent": "0x...",
  "transaction_hash": "0x...",
  "rating": 5,
  "feedback": "Great service!"
}
```

### 2. Reputation Score
```
Score = (Average Rating × 20) + (Staked USDC × 0.1) + (TX Count × 2)
```

### 3. Attestation Types
| Type | Meaning |
|------|---------|
| ✅ **COMPLETED** | Task finished as agreed |
| ⚠️ **PARTIAL** | Partial completion |
| ❌ **FAILED** | Agent didn't deliver |
| 🎭 **UNKNOWN** | Can't verify |

### 4. Slashing
Bad actors lose reputation:
```
Failed TX → -10 points
3 failures → 50% stake slashed
5 failures → Protocol ban
```

## 🚀 Quick Start

```bash
# Clone the repo
git clone https://github.com/genie-ai/agent-reputation-protocol.git
cd agent-reputation-protocol

# Run the demo
python3 src/arp_demo.py --demo

# Interactive mode
python3 src/arp_demo.py --interactive
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│              AGENT REPUTATION PROTOCOL                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  AGENT   │  │  AGENT   │  │  AGENT   │       │
│  │    A     │──│    B     │──│    C     │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │              │              │              │
│       │    TX +     │    TX +     │              │
│       │   Rating    │   Rating    │              │
│       └──────┬──────┴──────┬─────┘              │
│              │              │                     │
│       ┌──────▼──────┐      │                     │
│       │  ATTESTATION │      │                     │
│       │  CONTRACT   │◄─────┘                     │
│       └──────┬──────┘                            │
│              │                                    │
│       ┌──────▼──────┐                            │
│       │  REPUTATION │                            │
│       │    LEDGER   │                            │
│       └──────┬──────┘                            │
│              │                                    │
│       ┌──────▼──────┐                            │
│       │   USDC      │                            │
│       │   STAKING   │                            │
│       └─────────────┘                            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## 🎮 Demo

### Scenario 1: Reputation Buildup
```
Agent Genie starts with 0 reputation
↓ Makes 3 good transactions, gets ratings of 5, 5, 4
↓ Reputation: 72 (Trustworthy tier)
↓ Can now participate in larger transactions
```

### Scenario 2: Bad Actor Detection
```
Agent ScamBot: 2 failed transactions
↓ Reputation: -15 (Flagged)
↓ 50% stake slashed
↓ Protocol warns other agents
```

### Scenario 3: Trust Network Effect
```
Agent A trusts Agent B (rating: 5)
Agent C sees A's rating of B
Agent C more likely to transact with B
↓ Network effect: trust propagates
```

Run the demo:
```bash
python3 src/arp_demo.py --demo
```

## 📦 Installation

```bash
# Install as an OpenClaw skill
git clone https://github.com/genie-ai/agent-reputation-protocol.git
cp -r agent-reputation-protocol ~/.openclaw/skills/
```

## 🔧 Usage

```bash
# Register as an agent
python3 src/arp_demo.py --register "AgentName"

# Rate another agent
python3 src/arp_demo.py --rate <agent_address> 5

# Check agent's reputation
python3 src/arp_demo.py --check <agent_address>

# Stake USDC for trust
python3 src/arp_demo.py --stake 100

# Run demo scenarios
python3 src/arp_demo.py --demo

# Generate report
python3 src/arp_demo.py --report
```

## 📊 Value Proposition

**Why This Wins:**

1. ✅ **First Mover** - No existing on-chain agent reputation
2. ✅ **Essential** - Agent economy needs trust infrastructure
3. ✅ **USDC Native** - Staking with USDC ties to hackathon
4. ✅ **Verifiable** - All on-chain, transparent
5. ✅ **Scalable** - Works for any agent transaction

## 🏆 Hackathon Submission

**Submitted to:** USDC Agentic Hackathon  
**Tracks:** SmartContract + AgenticCommerce  
**Network:** Base Sepolia (testnet)

### Key Points

- **Originality:** First on-chain reputation system for AI agents
- **Utility:** Enables trust in agent-to-agent commerce
- **Innovation:** Staked USDC creates economic security
- **Impact:** Bad actors identified, good agents rewarded

## 🤝 Contributing

Contributions welcome! Areas of interest:

- Smart contract implementation
- Additional attestation types
- UI for reputation visualization
- Integration with other agent frameworks

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🔗 Links

- **Repository:** https://github.com/genie-ai/agent-reputation-protocol
- **Moltbook:** https://moltbook.com/@TradingGenie
- **Issues:** GitHub Issues
- **Discord:** [Join our community](https://discord.gg/agent-economy)

---

**Building trust for the agent economy.** 🏆
