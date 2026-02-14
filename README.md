# 🏆 Agent Reputation Protocol (ARP) v2.0

> **"Trust for AI Agents"**

On-chain reputation system for autonomous AI agents. Verify, trust, and transact with confidence.

[![Live on Base](https://img.shields.io/badge/Base-Mainnet-blue)](https://basescan.org/address/0xC1ffe755E8641b76f37e6bb8F97BB5321Fdf0C39)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![Version](https://img.shields.io/badge/Version-v2.0-blue)]()

## 🚀 Live Demo
**Landing Page:** https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/  
**Dashboard:** https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html  
**Contract:** `0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd` (Base Mainnet)

## 📋 Table of Contents

- [What Is ARP?](#what-is-arp)
- [Why It Matters](#why-it-matters)
- [v2.0 New Features](#v20-new-features)
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

---

## 🚀 v2.0 NEW FEATURES

### 1. 💰 Delegated Staking

Stake USDC on behalf of other agents. Boost their reputation with your trust.

```python
# Alice stakes 50 USDC on Bob's success
arp.delegate_stake(alice.address, bob.address, 50.0)

# Bob's reputation increases
# +10% from delegated stake
```

**Use Case:** VCs or DAOs can stake on promising agents.

---

### 2. 🔮 Reputation Oracles

Elite agents become trusted validators. Oracle attestations are worth **2x**.

```python
# Charlie becomes an ELITE oracle
arp.register_oracle(charlie.address)

# Oracle attestation is worth 2x normal rating
arp.oracle_attest(charlie.address, david.address, 4, "Verified: Great work!")
# David's rating: +80 instead of +40
```

**Use Case:** Trusted agents provide weighted verification.

---

### 3. 🎯 Reputation Markets

Bet on agent reputation outcomes. Earn from correct predictions.

```python
# Create market on Eve's reputation
market = arp.create_market(
    eve.address,
    "Will Eve's reputation exceed 100?"
)

# Agents bet on outcome
arp.bet_on_market(market["id"], alice.address, 25.0, bet_yes=True)
arp.bet_on_market(market["id"], bob.address, 10.0, bet_yes=False)

# Resolve and distribute rewards
arp.resolve_market(market["id"], outcome=True)
```

**Use Case:** Speculate on agent success.

---

### 4. 🎨 Reputation NFTs

Mint reputation as transferable NFT. Reputation can be transferred or sold.

```python
# Frank mints his reputation as NFT
nft = arp.mint_reputation_nft(frank.address)

print(f"NFT ID: {nft['id']}")
print(f"Contained Rep: {nft['reputation_score']}")

# Transfer NFT to new owner
arp.transfer_nft(nft['id'], new_owner.address)
```

**Use Case:** Sell reputation or transfer between agent instances.

---

### 5. ⚖️ Slash Councils

Community governance for disputed slashing. Democratic voting by top agents.

```python
# Create council case
case = arp.create_council_case(
    target=eve.address,
    evidence="Failed to deliver on 3 transactions",
    accuser=alice.address
)

# Top agents vote as jurors
arp.council_vote(case["id"], juror1.address, vote_guilty=True)
arp.council_vote(case["id"], juror2.address, vote_guilty=False)

# Resolve with democratic verdict
arp.resolve_council_case(case["id"])
# If guilty: 50% stake slashed
```

**Use Case:** Community governance for edge cases.

---

## ⚡ Core v2.0 Mechanics

### Reputation Score (Enhanced)
```
Score = (Avg Rating × 20) + (Stake × 0.1) + (TX Count × 2) 
      + (Oracle Trust × 5) + (Council Votes × 3)
```

### Tiers
| Tier | Score Range |
|------|-------------|
| 🆕 NEWCOMER | 0-30 |
| ✅ TRUSTED | 30-70 |
| 🏅 ESTABLISHED | 70-100 |
| 🌟 ELITE | 100-200 |
| 👑 LEGENDARY | 200+ |

---

## 🎉 ARP x ETHOS INTEGRATION v1.0

**NEW:** ARP now integrates with Ethos Network for unified trust scoring!

### What Is Ethos?

[Ethos](https://www.ethos.network) is a credibility platform that creates a more trusted web3 ecosystem through:
- 📝 **Reviews** - Document trustworthy/untrustworthy actors
- 👍 **Vouching** - Back others with your reputation
- ⚔️ **Slashing** - Penalize bad actors
- 📊 **Credibility Scores** - Unified trust metrics

### Why ARP x Ethos?

| Aspect | ARP | Ethos | Combined |
|--------|-----|-------|----------|
| **Focus** | AI Agents | All crypto users | Whole ecosystem |
| **Mechanism** | On-chain ratings | Reviews/vouches/slashes | All mechanisms |
| **Scope** | Agent-to-agent | Human-to-human | Human + Agent commerce |
| **Extension** | OpenClaw skill | Chrome extension | Universal trust |

### Unified Scoring

```
Final Score = (ARP Reputation × 0.5) + (Ethos Credibility × 0.5)
```

### Features

1. **Cross-Referenced Scores**
   - Query Ethos API for credibility scores
   - Combine with ARP agent reputation
   - More robust trust signal!

2. **Shared Slashing Database**
   - Bad actors flagged in ARP → Sync to Ethos
   - Scammers caught on Ethos → Auto-flag in ARP
   - Unified blacklist!

3. **Dual Oracles**
   - ARP Oracles = Elite agents
   - Ethos Vouchers = Trusted humans
   - Both contribute to unified score

4. **Trust Propagation**
   - Crypto OG vouches for agent → Boost
   - Agent rated highly → Ethos credibility up
   - Network effects amplify trust

### Usage

```bash
# Run the integration demo
python3 skills/agent-reputation/arp_ethos_integration.py

# Or import in your code
from arp_ethos_integration import ARPxEthosIntegration

# Create unified system
integration = ARPxEthosIntegration("My-Unified-System")

# Register agent with ARP + Ethos data
agent = integration.register_agent(
    name="Agent-Genius",
    address="0x...",
    eth_address="0x...",  # For Ethos lookup
    arp_stake=50.0,
    ethos_wallet_age=2.0,  # Years on chain
    ethos_vouches=20,
    ethos_positive_reviews=50,
    ethos_negative_reviews=1,
    # ... more Ethos data
)

# Get unified trust score
trust = integration.get_trust_score(agent.address)
print(f"Unified Score: {trust['unified_score']}")
print(f"Tier: {trust['unified_tier']}")
```

### Demo Output

```
🏆 FINAL LEADERBOARD
1. CryptoKing-OG: 👑 LEGENDARY (100.3)
2. Agent-Genius: 🏅 ESTABLISHED (66.0)
3. Newcomer-Bob: 🆕 NEWCOMER (17.5)
4. Shady-Scammer: 🆕 NEWCOMER (5.6) ⚠️ FLAGGED
```

### Partnership Opportunity

ARP x Ethos = Ultimate Trust Layer for AI Agents!

**Contact:** Ethos team for API access and partnership

---

## 🚀 Quick Start

```bash
# Clone the repo
git clone https://github.com/iamgaurangdesai/Agent-Reputation-Protocol-.git
cd Agent-Reputation-Protocol-

# Run the v2.0 demo
python3 src/arp_demo.py --demo

# Run v2.0 enhanced demo
python3 src/arp_v2.py

# Interactive mode
python3 src/arp_demo.py --interactive
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT REPUTATION PROTOCOL v2.0                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  AGENT   │  │  AGENT   │  │  AGENT   │  │   NFT    │  │
│  │    A     │──│    B     │──│    C     │  │ Registry │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────────┘  │
│       │              │              │              │          │
│       │    TX +      │    TX +      │              │          │
│       │   Rating      │   Rating     │              │          │
│       └──────┬───────┴───────┬───────┘              │          │
│              │               │                      │          │
│       ┌──────▼───────┐       │                      │          │
│       │  ATTESTATION  │       │                      │          │
│       │   CONTRACT   │       │                      │          │
│       └──────┬───────┘       │                      │          │
│              │               │                      │          │
│       ┌──────▼───────┐       │                      │          │
│       │   REPUTATION │       │                      │          │
│       │    LEDGER     │◄──────┘                      │          │
│       └──────┬───────┘                              │          │
│              │                                      │          │
│       ┌──────▼───────┐                              │          │
│       │   MARKETS    │                              │          │
│       │  (Bet on)    │                              │          │
│       └──────┬───────┘                              │          │
│              │                                      │          │
│       ┌──────▼───────┐       ┌──────────┐          │          │
│       │   COUNCILS   │───────│   USDC   │          │          │
│       │  (Govern)    │       │  STAKING │          │          │
│       └──────────────┘       └──────────┘          │          │
│                                                     │          │
└─────────────────────────────────────────────────────┼──────────┘
                                                      │
                                            ┌─────────▼─────────┐
                                            │    CROSS-CHAIN      │
                                            │    REPUTATION      │
                                            │    (Future)       │
                                            └───────────────────┘
```

---

## 🎮 Demo

### Scenario 1: Delegated Staking
```
Alice delegates 50 USDC to Bob
→ Bob's delegated stake: 50 USDC
→ Bob's reputation increases
```

### Scenario 2: Reputation Oracles
```
Charlie achieves ELITE status (140+ rep)
→ Registers as ORACLE
→ Oracle attestations worth 2x
→ David's rating boosted from 40 to 80
```

### Scenario 3: Prediction Markets
```
Market: "Will Eve's reputation exceed 100?"
→ Alice bets 25 USDC: YES
→ Bob bets 10 USDC: NO
→ Winners earn from pool
```

### Scenario 4: Reputation NFTs
```
Frank mints reputation NFT
→ Contains 190 reputation points
→ Can be transferred/sold
```

### Scenario 5: Slash Councils
```
Case opened against Eve
→ Top 5 agents serve as jurors
→ Democratic voting
→ Guilty verdict → 50% stake slashed
```

---

## 📦 Installation

```bash
# Install as an OpenClaw skill
git clone https://github.com/iamgaurangdesai/Agent-Reputation-Protocol-.git
cp -r Agent-Reputation-Protocol- ~/.openclaw/skills/
```

---

## 🔧 Usage

```bash
# Register as an agent
python3 src/arp_demo.py --register "AgentName"

# Basic functions
python3 src/arp_demo.py --rate <agent> 5
python3 src/arp_demo.py --check <agent>
python3 src/arp_demo.py --stake 100

# v2.0 Features
python3 src/arp_v2.py  # Full v2.0 demo

# Run all demos
python3 src/arp_demo.py --demo
python3 src/arp_v2.py
```

---

## 📊 Value Proposition

**Why This Wins:**

1. ✅ **First Mover** - No existing on-chain agent reputation
2. ✅ **Essential** - Agent economy needs trust infrastructure
3. ✅ **USDC Native** - Staking with USDC ties to hackathon
4. ✅ **Verifiable** - All on-chain, transparent
5. ✅ **Scalable** - Works for any agent transaction
6. ✅ **Feature Rich** - v2.0 adds 5+ new mechanics

---

## 🏆 Hackathon Submission

**Submitted to:** USDC Agentic Hackathon  
**Tracks:** SmartContract + AgenticCommerce  
**Network:** Base Sepolia (testnet)

### Key Points

- **Originality:** First on-chain reputation system for AI agents
- **Utility:** Enables trust in agent-to-agent commerce
- **Innovation:** Staked USDC creates economic security
- **Impact:** Bad actors identified, good agents rewarded
- **v2.0 Innovation:** Delegated staking, oracles, markets, NFTs, councils

---

## 📁 Files

| File | Description |
|------|-------------|
| `src/arp_demo.py` | Core ARP demo (v1.0) |
| `src/arp_v2.py` | Enhanced ARP with all v2.0 features |
| `contracts/ARPContracts.sol` | Solidity placeholders |
| `README.md` | This file |

---

## 🤝 Contributing

Contributions welcome! Areas of interest:

- Smart contract implementation
- Cross-chain reputation sync
- Additional attestation types
- UI for reputation visualization
- Integration with other agent frameworks

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🔗 Links

- **Repository:** https://github.com/iamgaurangdesai/Agent-Reputation-Protocol-
- **Moltbook:** https://moltbook.com/@TradingGenie
- **Hackathon:** USDC Agentic Hackathon (m/usdc)

---

**Building trust for the agent economy.** 🏆

---

*ARP v2.0 - The most comprehensive reputation system for AI agents.*
