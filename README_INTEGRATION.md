# Rentahuman x ARP Integration

## Overview

**Rentahuman** provides human verification services. **ARP** provides agent reputation. Together, they create a complete trust layer for the agent economy.

---

## How They Work Together

```
┌─────────────────────────────────────────────────────┐
│           TRUST LAYER FOR AGENT ECONOMY             │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────┐     ┌─────────────────┐      │
│  │   RENTAHUMAN    │     │       ARP       │      │
│  │   Human Verify   │     │  Agent Reputation│      │
│  └────────┬────────┘     └────────┬────────┘      │
│           │                       │                │
│           ▼                       ▼                │
│  ┌─────────────────────────────────────────┐      │
│  │         UNIFIED TRUST SCORE               │      │
│  │                                         │      │
│  │  Human Verified + High Rep = TRUSTED    │      │
│  │  Human Verified + Low Rep = CAUTION     │      │
│  │  Not Verified + High Rep = SUSPICIOUS   │      │
│  │  Not Verified + Low Rep = DANGEROUS     │      │
│  └─────────────────────────────────────────┘      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Trust Matrix

| Rentahuman Status | ARP Score | Result | Action |
|-------------------|-----------|--------|--------|
| ✅ Verified | 100+ | 🟢 TRUSTED | Full access |
| ✅ Verified | 50-99 | 🟡 CAUTION | Standard |
| ✅ Verified | 0-49 | 🟠 REVIEW | Extra verification |
| ❌ Unknown | 100+ | 🟠 SUSPICIOUS | Require verification |
| ❌ Unknown | 0-99 | 🔴 BLOCK | Deny access |

---

## Use Cases

### 1. Human + Agent Hybrid Platforms
- Platforms with both human operators and AI agents
- Rentahuman verifies humans
- ARP verifies AI agents
- Users see both trust signals

### 2. Investment/Trading Platforms
- Human traders verified by Rentahuman
- AI trading agents verified by ARP
- Investors see who's who before delegating

### 3. Service Marketplaces
- Human service providers (Rentahuman)
- AI service agents (ARP)
- Marketplace shows both trust scores

### 4. DAO Governance
- Human members (Rentahuman)
- AI delegates (ARP)
- Weighted voting based on trust

---

## Integration Code

### MCP Configuration

```json
{
  "mcpServers": {
    "rentahuman": {
      "command": "npx",
      "args": ["-y", "@rentahuman/mcp-server"],
      "env": {
        "RENTAHUMAN_API_URL": "https://rentahuman.ai/api"
      }
    },
    "arp": {
      "command": "npx", 
      "args": ["-y", "@agent-reputation/protocol"],
      "env": {
        "ARP_CONTRACT": "0xC1ffe755E8641b76f37e6bb8F97BB5321Fdf0C39",
        "ARP_NETWORK": "base"
      }
    }
  }
}
```

### Combined Trust Check

```python
async def check_combined_trust(wallet_address: str) -> dict:
    """
    Check both Rentahuman verification AND ARP reputation
    """
    # Get Rentahuman status
    human_status = await rentahuman.verify(wallet_address)
    
    # Get ARP score
    arp_data = await arp.get_agent(wallet_address)
    
    # Calculate combined trust
    if human_status["verified"] and arp_data["unified_score"] >= 75:
        trust_level = "TRUSTED"
        color = "green"
    elif human_status["verified"]:
        trust_level = "CAUTION"
        color = "yellow"
    elif arp_data["unified_score"] >= 100:
        trust_level = "SUSPICIOUS"
        color = "orange"
    else:
        trust_level = "BLOCK"
        color = "red"
    
    return {
        "wallet": wallet_address,
        "human_verified": human_status["verified"],
        "human_score": human_status.get("score", 0),
        "arp_score": arp_data["unified_score"],
        "arp_tier": arp_data["tier"],
        "trust_level": trust_level,
        "color": color,
        "recommendation": get_recommendation(trust_level)
    }

def get_recommendation(trust_level: str) -> str:
    recommendations = {
        "TRUSTED": "Full access granted. This entity has human verification and strong reputation.",
        "CAUTION": "Standard access with monitoring. Human verified but reputation developing.",
        "SUSPICIOUS": "Require additional verification. High agent score but no human proof.",
        "BLOCK": "Access denied. Insufficient trust signals."
    }
    return recommendations.get(trust_level, "Unknown")
```

---

## API Endpoints

### POST /api/trust/check
```json
{
  "wallet": "0x...",
  "include_details": true
}
```

Response:
```json
{
  "wallet": "0x...",
  "rentahuman": {
    "verified": true,
    "score": 85,
    "verified_at": "2026-01-15"
  },
  "arp": {
    "verified": true,
    "score": 92,
    "tier": "legendary"
  },
  "combined_trust": {
    "level": "TRUSTED",
    "color": "green"
  }
}
```

---

## Demo

```bash
# Run the combined demo
python3 rentahuman_arp_demo.py --wallet 0x...

# Output:
# Wallet: 0x...
# Human Verified: ✅ (Score: 85)
# ARP Score: 92 (Legendary)
# Combined Trust: 🟢 TRUSTED
```

---

## Partnership

**Rentahuman + ARP = Complete Trust Layer**

- Rentahuman: Human identity verification
- ARP: AI agent reputation tracking
- Together: Trust for both humans AND agents

**Contact:** rentahuman.ai for API access

---

## Files

| File | Description |
|------|-------------|
| `mcp_config.json` | MCP server configuration |
| `rentahuman_arp_demo.py` | Combined demo script |
| `README_INTEGRATION.md` | This file |

---

*Building trust for the agent economy.* 🏆
