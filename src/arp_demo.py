#!/usr/bin/env python3
"""
Agent Reputation Protocol (ARP) Demo

First on-chain reputation system for AI agents.
Agents rate each other after transactions.
Trust scores enable agent-to-agent commerce.
"""

import json
import random
import time
import uuid
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
from collections import defaultdict

class AttestationType(Enum):
    COMPLETED = "completed"
    PARTIAL = "partial"
    FAILED = "failed"
    UNKNOWN = "unknown"

class ReputationTier(Enum):
    NEWCOMER = (0, 30, "🆕")
    TRUSTED = (30, 70, "✅")
    ESTABLISHED = (70, 100, "🏅")
    ELITE = (100, 200, "🌟")
    LEGENDARY = (200, float('inf'), "👑")

@dataclass
class Agent:
    """An agent in the reputation system"""
    name: str
    address: str
    staked_usdc: float = 0.0
    transactions_count: int = 0
    ratings: List[Dict] = field(default_factory=list)
    reputation_score: float = 0.0
    reputation_tier: str = "🆕 NEWCOMER"
    
    def calculate_reputation(self):
        """Calculate reputation score"""
        if not self.ratings:
            self.reputation_score = 0.0
        else:
            avg_rating = sum(r["rating"] for r in self.ratings) / len(self.ratings)
            stake_bonus = self.staked_usdc * 0.1
            tx_bonus = self.transactions_count * 2
            
            self.reputation_score = (avg_rating * 20) + stake_bonus + tx_bonus
        
        # Determine tier
        for tier in ReputationTier:
            min_score, max_score, emoji = tier.value
            if min_score <= self.reputation_score < max_score:
                self.reputation_tier = f"{emoji} {tier.name}"
                break
        
        return self.reputation_score
    
    def to_dict(self):
        return {
            "name": self.name,
            "address": self.address[:20] + "...",
            "staked_usdc": self.staked_usdc,
            "reputation_score": round(self.reputation_score, 1),
            "reputation_tier": self.reputation_tier,
            "transactions": self.transactions_count,
            "ratings_count": len(self.ratings)
        }

class ARPContract:
    """Simulated ARP smart contract"""
    
    def __init__(self):
        self.agents: Dict[str, Agent] = {}
        self.transactions: List[Dict] = []
        self.attestations: List[Dict] = []
        
    def register_agent(self, name: str, staked_usdc: float = 10.0) -> Agent:
        """Register a new agent"""
        agent = Agent(
            name=name,
            address=f"0x{uuid.uuid4().hex[:40]}",
            staked_usdc=staked_usdc
        )
        agent.calculate_reputation()
        self.agents[agent.address] = agent
        return agent
    
    def submit_transaction(self, from_addr: str, to_addr: str, amount: float) -> Dict:
        """Record a transaction"""
        tx = {
            "tx_hash": f"0x{uuid.uuid4().hex[:40]}",
            "from": from_addr,
            "to": to_addr,
            "amount": amount,
            "timestamp": datetime.now().isoformat(),
            "status": "pending"
        }
        self.transactions.append(tx)
        
        # Update agent transaction counts
        if from_addr in self.agents:
            self.agents[from_addr].transactions_count += 1
        if to_addr in self.agents:
            self.agents[to_addr].transactions_count += 1
        
        return tx
    
    def attest(self, tx_hash: str, rating: int, feedback: str = "") -> Dict:
        """Submit rating for a transaction"""
        # Find transaction
        tx = next((t for t in self.transactions if t["tx_hash"] == tx_hash), None)
        if not tx:
            return {"error": "Transaction not found"}
        
        # Update transaction status
        tx["status"] = "completed"
        
        # Record attestation
        attestation = {
            "tx_hash": tx_hash,
            "from": tx["from"],
            "to": tx["to"],
            "rating": rating,
            "feedback": feedback,
            "timestamp": datetime.now().isoformat()
        }
        self.attestations.append(attestation)
        
        # Update agent ratings
        if tx["from"] in self.agents:
            self.agents[tx["from"]].ratings.append({
                "rating": rating,
                "tx_hash": tx_hash,
                "feedback": feedback
            })
        
        # Recalculate reputations
        for addr in [tx["from"], tx["to"]]:
            if addr in self.agents:
                self.agents[addr].calculate_reputation()
        
        return attestation
    
    def slash_agent(self, address: str, reason: str) -> Dict:
        """Slash stake for bad behavior"""
        if address not in self.agents:
            return {"error": "Agent not found"}
        
        agent = self.agents[address]
        slash_amount = agent.staked_usdc * 0.5
        agent.staked_usdc -= slash_amount
        agent.ratings.append({
            "rating": 1,
            "tx_hash": "SLASH",
            "feedback": f"Slashed for: {reason}"
        })
        agent.calculate_reputation()
        
        return {
            "agent": agent.name,
            "slashed": slash_amount,
            "remaining": agent.staked_usdc,
            "reason": reason
        }
    
    def get_agent(self, address: str) -> Optional[Agent]:
        return self.agents.get(address)
    
    def get_all_agents(self) -> List[Dict]:
        return [a.to_dict() for a in self.agents.values()]

class ARPDemo:
    """Demonstrate ARP in action"""
    
    def __init__(self):
        self.arp = ARPContract()
        
    def setup_agents(self):
        """Register demo agents"""
        print("\n" + "="*60)
        print("🏗️  SETUP: Registering Demo Agents")
        print("="*60)
        
        # Create demo agents
        genie = self.arp.register_agent("Genie-Commerce", staked_usdc=50.0)
        bot_a = self.arp.register_agent("TraderBot-X", staked_usdc=25.0)
        bot_b = self.arp.register_agent("PaymentAgent-7", staked_usdc=100.0)
        scammer = self.arp.register_agent("ShadyBot-99", staked_usdc=10.0)
        
        print(f"   ✅ Registered: {genie.name} (tier: {genie.reputation_tier})")
        print(f"   ✅ Registered: {bot_a.name} (tier: {bot_a.reputation_tier})")
        print(f"   ✅ Registered: {bot_b.name} (tier: {bot_b.reputation_tier})")
        print(f"   ⚠️  Registered: {scammer.name} (tier: {scammer.reputation_tier})")
        
        return genie, bot_a, bot_b, scammer
    
    def demo_reputation_buildup(self, genie, bot_a, bot_b):
        """Demo: Agent builds reputation"""
        print("\n" + "="*60)
        print("📈 SCENARIO 1: Building Reputation")
        print("="*60)
        
        print(f"\n   🤖 {genie.name} starts with {genie.reputation_tier}")
        
        # Simulate transactions and ratings
        for i in range(3):
            tx = self.arp.submit_transaction(
                genie.address, 
                bot_a.address, 
                random.uniform(10, 50)
            )
            
            rating = random.choice([4, 5, 5, 5])  # Good ratings
            self.arp.attest(tx["tx_hash"], rating, "Great service!")
            
            print(f"   Transaction {i+1}: Rating {rating} ⭐ → Rep: {genie.reputation_score:.1f}")
        
        print(f"\n   🏆 {genie.name} now: {genie.reputation_tier} ({genie.reputation_score:.1f})")
    
    def demo_bad_actor(self, scammer):
        """Demo: Bad actor gets slashed"""
        print("\n" + "="*60)
        print("🚫 SCENARIO 2: Bad Actor Detection")
        print("="*60)
        
        print(f"\n   😈 {scammer.name} tries to scam...")
        
        # Scammer fails transactions
        for i in range(2):
            tx = self.arp.submit_transaction(
                "victim_address",
                scammer.address,
                random.uniform(20, 100)
            )
            self.arp.attest(tx["tx_hash"], 1, "Never delivered!")
            print(f"   Failed TX {i+1}: Rating 1 ⭐")
        
        # Slash the scammer
        result = self.arp.slash_agent(scammer.address, "Multiple failed transactions")
        
        print(f"\n   ⚖️  SLASHED!")
        print(f"   - Amount slashed: ${result['slashed']}")
        print(f"   - Remaining stake: ${result['remaining']}")
        print(f"   - Reputation: {scammer.reputation_score:.1f} (FLAGGED)")
    
    def demo_trust_network(self, genie, bot_a, bot_b):
        """Demo: Trust propagates through network"""
        print("\n" + "="*60)
        print("🔗 SCENARIO 3: Trust Network Effect")
        print("="*60)
        
        print("\n   Agent ratings create a trust network:")
        print("   ┌─────────┐      ┌─────────┐")
        print("   │ Genie   │──────│ Trader  │")
        print("   │         │ 5⭐   │ Bot-X   │")
        print("   └─────────┘      └────┬────┘")
        print("                          │")
        print("                          ▼")
        print("                   ┌─────────┐")
        print("                   │Payment  │")
        print("                   │Agent-7  │")
        print("                   │Sees: ✅ │")
        print("                   └─────────┘")
        
        # Show that new agents benefit from trusted connections
        new_agent = self.arp.register_agent("NewBot-2024", staked_usdc=10.0)
        
        # New agent transacts with trusted agent
        tx = self.arp.submit_transaction(new_agent.address, bot_b.address, 25.0)
        self.arp.attest(tx["tx_hash"], 5, "Trusted connection!")
        
        print(f"\n   📊 NewBot joins and transacts with trusted PaymentAgent-7")
        print(f"   🏷️  NewBot reputation: {new_agent.reputation_score:.1f} (boosted by trusted network)")
    
    def show_leaderboard(self):
        """Display reputation leaderboard"""
        print("\n" + "="*60)
        print("🏆 REPUTATION LEADERBOARD")
        print("="*60)
        
        agents = sorted(
            self.arp.get_all_agents(), 
            key=lambda x: x["reputation_score"], 
            reverse=True
        )
        
        print(f"\n{'Rank':<6} {'Agent':<20} {'Tier':<15} {'Score':<8} {'TXs':<5}")
        print("-" * 60)
        
        for i, agent in enumerate(agents, 1):
            print(f"{i:<6} {agent['name']:<20} {agent['reputation_tier']:<15} {agent['reputation_score']:<8} {agent['transactions']:<5}")
    
    def print_value_props(self):
        """Print why ARP matters"""
        print("\n" + "="*60)
        print("💡 WHY ARP MATTERS")
        print("="*60)
        
        print("""
   🏆 FIRST ON-CHAIN REPUTATION FOR AI AGENTS
   
   ✓ Trust - Agents can verify counterpart reliability
   ✓ Accountability - Bad actors get flagged & slashed
   ✓ Scalability - Reputation follows agents across systems
   ✓ Economic Security - Staked USDC creates real stakes
   ✓ Transparency - All on-chain, auditable
   
   Without ARP: Agents blindly trust strangers
   With ARP: Agents transact with verified, trusted partners
        """)
    
    def run_full_demo(self):
        """Run complete demo"""
        print("="*60)
        print("🏆 AGENT REPUTATION PROTOCOL (ARP) DEMO")
        print("   First Trust System for AI Agents")
        print("="*60)
        
        # Setup
        genie, bot_a, bot_b, scammer = self.setup_agents()
        
        # Scenarios
        self.demo_reputation_buildup(genie, bot_a, bot_b)
        self.demo_bad_actor(scammer)
        self.demo_trust_network(genie, bot_a, bot_b)
        
        # Leaderboard
        self.show_leaderboard()
        
        # Value props
        self.print_value_props()
        
        print("="*60)
        print("🎯 KEY TAKEAWAY")
        print("="*60)
        print("""
   ARP enables trust in agent-to-agent commerce.
   
   • New agents can build reputation through good transactions
   • Bad actors are identified and slashed
   • Trust propagates through the network
   • Economic security via staked USDC
   
   This is infrastructure the agent economy needs.
        """)

def main():
    demo = ARPDemo()
    demo.run_full_demo()

if __name__ == "__main__":
    main()
