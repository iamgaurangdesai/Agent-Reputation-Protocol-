# EigenCloud Open Innovation Challenge - Submission Prep

**Deadline:** Feb 20, 11:59pm PT  
**Prize:** $10,000 + EigenCompute credits  
**Form:** https://docs.google.com/forms/d/e/1FAIpQLSdjCpocv1HibJOEMLtxBxbxleMOZoUIXSmUOT-B1QSv-7HLPg/viewform

---

## Required Fields

### 1. Name
Gaurang Desai

### 2. X (Twitter) handle
**NEEDED:** @your_twitter_handle

### 3. Email
**NEEDED:** your_email@example.com

### 4. Project name
**ARP (Agent Reputation Protocol) + EigenCloud Integration**

### 5. One-line description
**Verifiable reputation system for AI agents using EigenCloud TEE verification to cryptographically prove task completion and earn reputation multipliers.**

### 6. How did you use EigenCompute/EigenCloud?
**Full Answer:**

I built ARP (Agent Reputation Protocol), an on-chain reputation system for AI agents on Base Mainnet. The EigenCloud integration adds verifiable task execution:

**EigenCompute Integration:**
- Agents run in TEE-verified containers (EigenCompute)
- Generate cryptographic proofs of task completion
- Proof hashes stored on-chain with task records

**EigenCloud Extension Features:**
- `storeEigenAIProof()` - Agents using deterministic AI inference (EigenAI) submit verifiable proofs
- `storeTEEProof()` - TEE-attested execution proofs
- `storeFullProof()` - Combined EigenAI + TEE verification
- Reputation multipliers: 1.2x (EigenAI) → 1.5x (TEE) → 2.0x (Full)
- Proof deduplication and timestamp validation
- Emergency pause and access controls

**Technical Implementation:**
- Contracts deployed on Base Mainnet
- EigenCloud Extension V2: 0x72aa0fa6bD35Cd6A5B0d1dB0591fDe9F844E5f66
- ARP Contract: 0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd
- Frontend: GitHub Pages with MetaMask integration
- One-command installer for AI agents

### 7. Demo link
**Primary:** https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/  
**Dashboard:** https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html  
**GitHub:** https://github.com/iamgaurangdesai/Agent-Reputation-Protocol-

### 8. Tweet announcement link
**NEEDED:** Create tweet tagging @eigencloud with:
- Demo video or screenshot
- Contract addresses
- One-line pitch
- GitHub link

---

## Assets Needed

### For Tweet:
- [ ] Demo video (30-60 seconds)
- [ ] Screenshot of dashboard
- [ ] Screenshot of verification flow

### For Form:
- [ ] Your Twitter handle
- [ ] Your email

---

## Submission Checklist

- [ ] Fill Google Form with above info
- [ ] Post announcement tweet tagging @eigencloud
- [ ] Add tweet link to form
- [ ] Submit before Feb 20, 11:59pm PT

---

## Key Metrics to Highlight

| Metric | Value |
|--------|-------|
| Contracts Deployed | 3 (ARP + EigenCloud V2 + Testnet versions) |
| Network | Base Mainnet |
| Tests Passed | Full end-to-end flow verified |
| Agent Registrations | Tested with TestAgent (130 reputation, 4 verified tasks) |
| Installation | One-command: `curl -s .../install.sh \| bash` |
| GitHub Stars | **NEEDED** |
| Unique Visitors | **NEEDED** |

---

## Project Highlights

1. **Real Utility** - Solves trust problem in agent economy
2. **EigenCloud Native** - Built specifically for TEE/AI verification
3. **Production Ready** - Deployed on Base Mainnet, fully functional
4. **Open Source** - Complete codebase on GitHub
5. **No Token** - Pure reputation, no speculative token
