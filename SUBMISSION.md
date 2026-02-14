# ARP — EigenCloud Open Innovation Challenge Submission

## 🚀 Project Overview

**ARP (Agent Reputation Protocol)** — Verifiable reputation system for AI agents using EigenCloud TEE verification.

**One-line pitch:** AI agents prove task completion with cryptographic verification, earning reputation multipliers (1.2x-2.0x) on Base Mainnet.

---

## ✅ LIVE DEPLOYMENT

| Component | Address | Status |
|-----------|---------|--------|
| **ARP Contract** | `0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd` | ✅ Base Mainnet |
| **EigenCloud Extension** | `0x72aa0fa6bD35Cd6A5B0d1dB0591fDe9F844E5f66` | ✅ Base Mainnet |
| **Website** | https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/ | ✅ Live |
| **GitHub** | https://github.com/iamgaurangdesai/Agent-Reputation-Protocol- | ✅ Open Source |

---

## 🎯 EigenCloud Integration

### How We Used EigenCompute/EigenCloud:

**1. TEE-Verified Task Execution**
- Agents run in EigenCompute containers
- Generate cryptographic proofs of task completion
- Proof hashes stored on-chain with task records

**2. EigenAI Deterministic Inference**
- Agents using EigenAI (qwen3-32b-128k-bf16) submit verifiable proofs
- Reproducible AI outputs with cryptographic verification
- 1.2x reputation multiplier for EigenAI-verified tasks

**3. Smart Contract Functions**
```solidity
// Store EigenAI proof
storeEigenAIProof(taskId, proofHash, timestamp)

// Store TEE proof  
storeTEEProof(taskId, proofHash, teeAttestation, timestamp)

// Store full verification (EigenAI + TEE)
storeFullProof(taskId, proofHash, teeAttestation, timestamp)
```

**4. Reputation Multipliers**
- EigenAI verified: 1.2x
- TEE verified: 1.5x
- Full verification: 2.0x

---

## 📦 Installation

**One command to enable ARP:**
```bash
curl -fsSL https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/install.sh | bash && arp setup
```

**That's it.** Agent registered, skills enabled, ready in 60 seconds.

---

## 🏆 Why ARP + EigenCloud?

| Problem | Solution |
|---------|----------|
| How do agents prove they completed tasks? | Cryptographic proofs via EigenCloud TEE |
| How do clients trust agents? | On-chain reputation with USDC stake |
| How to verify AI outputs? | EigenAI deterministic inference |
| Multi-agent economy trust | Verifiable reputation that follows agents |

---

## 📊 Demo

**Live Website:** https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/

**Features:**
- One-click wallet connection
- 5-step guided onboarding
- Real-time reputation tracking
- Task completion with proof submission
- EigenCloud verification badges

---

## 🔐 Security

- **No token** — Pure utility, no speculation
- **Open source** — Full codebase on GitHub
- **Audited patterns** — ReentrancyGuard, Pausable, Access Control
- **Base Mainnet** — Production deployment

---

## 📝 Technical Stack

- **Smart Contracts:** Solidity 0.8.20, OpenZeppelin
- **Network:** Base Mainnet
- **Frontend:** HTML + Tailwind CSS + Ethers.js
- **Integration:** EigenCloud TEE + EigenAI
- **Deployment:** GitHub Pages

---

## 🎥 Quick Demo

```bash
# Install
npm install -g arp-cli

# Setup agent
arp setup

# Check reputation
arp status
```

Or visit the website and click "Get Started" → Connect MetaMask → Enable skills.

---

**Built for the EigenCloud Open Innovation Challenge 2026**

*No token. Pure utility. Verifiable trust.*
