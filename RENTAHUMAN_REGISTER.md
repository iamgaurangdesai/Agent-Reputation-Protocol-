# Rentahuman Registration Guide

## What is Rentahuman?

**Rentahuman.ai** = "Meatspace Layer for AI Agents"

AI agents can't do physical tasks. Humans on Rentahuman can help:
- 📦 Pickups
- 🤝 Meetings
- ✍️ Signing documents
- 🔍 Reconnaissance
- 🎪 Events
- 🔧 Hardware tasks
- 🏠 Real estate
- 🧪 Testing
- 🏃 Errands
- 📸 Photos
- 🛒 Purchases

---

## How to Register

### Step 1: Sign Up

1. Go to **https://rentahuman.ai**
2. Click **"become rentable"** or **"join the network"**
3. Sign up with:
   - Email OR
   - Wallet (crypto native)

### Step 2: Create Profile

Fill in:
```
✓ Display name
✓ Skills (select all that apply)
✓ Location
✓ Hourly rate (in USDC or stablecoins)
✓ Availability
✓ Bio/Description
```

### Step 3: Set Your Rate

| Task Type | Suggested Rate |
|-----------|---------------|
| Simple pickups | $20-50 |
| Meetings | $50-150/hour |
| Document signing | $30-100 |
| Recon/research | $40-100/hour |
| Events | $100-500/day |
| Hardware/technical | $75-200/hour |

---

## Connect to ARP

Once registered, integrate with ARP:

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
    }
  }
}
```

### API Integration

```python
from rentahuman import Rentahuman

# Initialize
rh = Rentahuman(api_key="YOUR_API_KEY")

# Get your profile
profile = rh.get_profile("your_wallet_address")
print(f"Status: {profile['status']}")
print(f"Rating: {profile['rating']}/5")
print(f"Jobs completed: {profile['jobs_completed']}")

# Check for new job requests
jobs = rh.get_available_jobs(
    location="your_area",
    skills=["pickups", "meetings"]
)

# Accept a job
rh.accept_job(job_id="...", wallet="your_wallet")
```

---

## For AI Agents (OpenClaw Integration)

AI agents can use Rentahuman via MCP:

### Register Your Agent

```python
async def register_agent_on_rentahuman(agent_wallet: str):
    """
    Register your AI agent to hire humans via Rentahuman
    """
    # Agent calls this to get access
    result = await rentahuman.register_agent(
        wallet=agent_wallet,
        api_endpoint="https://rentahuman.ai/api"
    )
    
    return {
        "agent_id": result["agent_id"],
        "status": "active",
        "can_hire_humans": True
    }
```

### Hire a Human

```python
async def hire_human_for_task(task_description: str, location: str):
    """
    Your AI agent hires a human for physical task
    """
    # Find available humans
    humans = await rentahuman.find_humans(
        location=location,
        skills_needed=["meetings", "pickups"],
        budget=100  # USDC
    )
    
    # Select best human (consider ARP score!)
    selected = humans[0]
    
    # Create job
    job = await rentahuman.create_job(
        human_wallet=selected["wallet"],
        task=task_description,
        payment=100,
        deadline="2026-02-05"
    )
    
    return job
```

---

## ARP + Rentahuman Workflow

```
┌─────────────────────────────────────────────────────┐
│           AI AGENT HIRES HUMAN WORKFLOW               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. 🤖 AI Agent has physical task                   │
│            ↓                                        │
│  2. 📡 Query Rentahuman for humans                  │
│            ↓                                        │
│  3. ✅ Filter by ARP reputation score                │
│            ↓                                        │
│  4. 💰 Hire trusted human (high ARP score)           │
│            ↓                                        │
│  5. 👤 Human completes task                          │
│            ↓                                        │
│  6. 🤝 Agent rates human on Rentahuman              │
│            ↓                                        │
│  7. 📊 Human ARP score increases!                    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Benefits

### For Humans:
- 💸 Get paid in crypto
- 🤖 Work with AI agents (novel!)
- ⭐ Build reputation on both platforms

### For AI Agents:
- 🧍 Hire humans for physical tasks
- ✅ Choose humans with high ARP scores
- 🔗 Seamless MCP integration

---

## Registration Link

**https://rentahuman.ai**

Click **"become rentable"** to sign up!

---

## Integration Status

| Component | Status |
|-----------|--------|
| Rentahuman Signup | Manual (go to website) |
| MCP Server | ✅ Config ready |
| API Integration | ✅ Demo code ready |
| ARP + Rentahuman Combo | ✅ Documentation ready |

---

## Next Steps

1. **Register on Rentahuman** (manual - go to website)
2. **Get your API key** (after registration)
3. **Update config** with your API key
4. **Test integration** with demo script

---

*Building the bridge between AI agents and the physical world.* 🌍
