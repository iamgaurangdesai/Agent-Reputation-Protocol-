#!/usr/bin/env python3
"""
ARP x Ethos Integration v1.0

Combines Agent Reputation Protocol (ARP) with Ethos Credibility Scores
for unified, cross-platform trust scoring.

Features:
- Query Ethos API for credibility scores
- Combined ARP + Ethos unified score
- Cross-referencing between systems
- Shared slashing database concept
"""

import json
import uuid
import time
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
from collections import defaultdict

# Ethos-style constants
ETHOS_API_BASE = "https://api.ethos.network/v1"
ETHEREUM_MAINNET = 1

class EthosCredibility(Enum):
    """Ethos credibility components"""
    WALLET_AGE = "wallet_age"
    VOUCHES_RECEIVED = "vouches_received"
    POSITIVE_REVIEWS = "positive_reviews"
    NEGATIVE_REVIEWS = "negative_reviews"
    SLASHES_AGAINST = "slashes_against"
    ATTESTATIONS = "attestations"
    CREDIBLE_VOUCHERS = "credible_vouchers"
    SYBIL_LIKELIHOOD = "sybil_likelihood"

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
    """Unified agent with ARP + Ethos scores"""
    name: str
    address: str
    eth_address: Optional[str] = None  # For Ethos lookup
    
    # ARP scores
    arp_stake: float = 0.0
    arp_delegated: float = 0.0
    arp_tx_count: int = 0
    arp_ratings: List[Dict] = field(default_factory=list)
    arp_score: float = 0.0
    arp_tier: str = "🆕 NEWCOMER"
    
    # Ethos scores (simulated - would query API in production)
    ethos_wallet_age: float = 0.0  # Years
    ethos_vouches: int = 0
    ethos_positive_reviews: int = 0
    ethos_negative_reviews: int = 0
    ethos_slashes: int = 0
    ethos_attestations: int = 0
    ethos_credible_vouchers: int = 0
    ethos_sybil_risk: float = 0.0  # 0-1 scale
    ethos_credibility_score: float = 0.0
    
    # Combined
    unified_score: float = 0.0
    unified_tier: str = "🆕"
    
    def calculate_arp_score(self):
        """Calculate ARP reputation score"""
        if not self.arp_ratings:
            self.arp_score = 0.0
        else:
            avg_rating = sum(r["rating"] for r in self.arp_ratings) / len(self.arp_ratings)
            stake_bonus = (self.arp_stake + self.arp_delegated) * 0.1
            tx_bonus = self.arp_tx_count * 2
            
            self.arp_score = (avg_rating * 20) + stake_bonus + tx_bonus
        
        for tier in ReputationTier:
            min_score, max_score, emoji = tier.value
            if min_score <= self.arp_score < max_score:
                self.arp_tier = f"{emoji} {tier.name}"
                break
        
        return self.arp_score
    
    def calculate_ethos_score(self):
        """Calculate Ethos credibility score (simulated)"""
        # In production, this would query Ethos API
        # For demo, we simulate based on factors
        
        base_score = 50.0  # Base credibility
        
        # Wallet age bonus (up to 20 points)
        wallet_bonus = min(self.ethos_wallet_age * 10, 20)
        
        # Vouches (up to 25 points)
        vouch_bonus = min(self.ethos_vouches * 5, 25)
        
        # Reviews (up to 25 points)
        review_score = (self.ethos_positive_reviews * 5) - (self.ethos_negative_reviews * 10)
        review_bonus = max(0, min(review_score, 25))
        
        # Attestations (up to 15 points)
        attestation_bonus = min(self.ethos_attestations * 3, 15)
        
        # Credible vouchers (up to 10 points)
        voucher_bonus = min(self.ethos_credible_vouchers * 2, 10)
        
        # Sybil penalty (up to -30 points)
        sybil_penalty = self.ethos_sybil_risk * 30
        
        # Slash penalty
        slash_penalty = self.ethos_slashes * 15
        
        self.ethos_credibility_score = (
            base_score +
            wallet_bonus +
            vouch_bonus +
            review_bonus +
            attestation_bonus +
            voucher_bonus -
            sybil_penalty -
            slash_penalty
        )
        
        return max(0, self.ethos_credibility_score)
    
    def calculate_unified_score(self, arp_weight: float = 0.5, ethos_weight: float = 0.5):
        """Calculate unified trust score"""
        self.arp_score = self.calculate_arp_score()
        self.ethos_credibility_score = self.calculate_ethos_score()
        
        # Normalize scores to 0-100 scale
        arp_normalized = min(self.arp_score / 2, 100)  # ARP usually 0-200
        ethos_normalized = self.ethos_credibility_score  # Already ~0-100
        
        self.unified_score = (arp_normalized * arp_weight) + (ethos_normalized * ethos_weight)
        
        # Determine unified tier
        if self.unified_score >= 90:
            self.unified_tier = "👑 LEGENDARY"
        elif self.unified_score >= 75:
            self.unified_tier = "🌟 ELITE"
        elif self.unified_score >= 50:
            self.unified_tier = "🏅 ESTABLISHED"
        elif self.unified_score >= 25:
            self.unified_tier = "✅ TRUSTED"
        else:
            self.unified_tier = "🆕 NEWCOMER"
        
        return self.unified_score
    
    def to_dict(self, include_all: bool = False):
        """Export agent data"""
        base = {
            "name": self.name,
            "address": self.address[:20] + "...",
            "arp_score": round(self.arp_score, 1),
            "arp_tier": self.arp_tier,
            "ethos_score": round(self.ethos_credibility_score, 1),
            "unified_score": round(self.unified_score, 1),
            "unified_tier": self.unified_tier,
        }
        
        if include_all:
            base.update({
                "arp_stake": self.arp_stake,
                "arp_delegated": self.arp_delegated,
                "arp_tx_count": self.arp_tx_count,
                "arp_ratings_count": len(self.arp_ratings),
                "ethos_wallet_age": self.ethos_wallet_age,
                "ethos_vouches": self.ethos_vouches,
                "ethos_positive_reviews": self.ethos_positive_reviews,
                "ethos_negative_reviews": self.ethos_negative_reviews,
                "ethos_slashes": self.ethos_slashes,
                "ethos_attestations": self.ethos_attestations,
                "ethos_credible_vouchers": self.ethos_credible_vouchers,
                "ethos_sybil_risk": self.ethos_sybil_risk,
            })
        
        return base


class ARPxEthosIntegration:
    """
    Unified Reputation System combining ARP and Ethos
    
    In production, this would:
    1. Query Ethos API for real credibility scores
    2. Submit ARP attestations to Ethos contract
    3. Sync slashing events between systems
    4. Calculate unified trust scores
    """
    
    def __init__(self, name: str = "ARPxEthos"):
        self.name = name
        self.agents: Dict[str, Agent] = {}
        self.transactions: List[Dict] = []
        self.attestations: List[Dict] = []
        self.shared_slashing_events: List[Dict] = []
        
    def register_agent(
        self, 
        name: str, 
        address: str, 
        eth_address: Optional[str] = None,
        arp_stake: float = 10.0,
        ethos_wallet_age: float = 0.0,
        ethos_vouches: int = 0,
        ethos_positive_reviews: int = 0,
        ethos_negative_reviews: int = 0,
        ethos_slashes: int = 0,
        ethos_attestations: int = 0,
        ethos_credible_vouchers: int = 0,
        ethos_sybil_risk: float = 0.1
    ) -> Agent:
        """Register a new agent with ARP + Ethos data"""
        agent = Agent(
            name=name,
            address=address,
            eth_address=eth_address,
            arp_stake=arp_stake,
            ethos_wallet_age=ethos_wallet_age,
            ethos_vouches=ethos_vouches,
            ethos_positive_reviews=ethos_positive_reviews,
            ethos_negative_reviews=ethos_negative_reviews,
            ethos_slashes=ethos_slashes,
            ethos_attestations=ethos_attestations,
            ethos_credible_vouchers=ethos_credible_vouchers,
            ethos_sybil_risk=ethos_sybil_risk
        )
        
        agent.calculate_unified_score()
        self.agents[address] = agent
        
        return agent
    
    def submit_transaction(self, from_addr: str, to_addr: str, amount: float) -> Dict:
        """Record a transaction between agents"""
        tx = {
            "tx_hash": f"0x{uuid.uuid4().hex[:40]}",
            "from": from_addr,
            "to": to_addr,
            "amount": amount,
            "timestamp": datetime.now().isoformat(),
            "status": "pending"
        }
        self.transactions.append(tx)
        
        if from_addr in self.agents:
            self.agents[from_addr].arp_tx_count += 1
        if to_addr in self.agents:
            self.agents[to_addr].arp_tx_count += 1
        
        return tx
    
    def attest_transaction(
        self, 
        tx_hash: str, 
        rating: int, 
        feedback: str = "",
        attest_type: str = "completed"
    ) -> Dict:
        """Attest a transaction (updates ARP + can sync to Ethos)"""
        tx = next((t for t in self.transactions if t["tx_hash"] == tx_hash), None)
        if not tx:
            return {"error": "Transaction not found"}
        
        tx["status"] = "completed"
        
        attestation = {
            "tx_hash": tx_hash,
            "from": tx["from"],
            "to": tx["to"],
            "rating": rating,
            "feedback": feedback,
            "type": attest_type,
            "timestamp": datetime.now().isoformat(),
            "platform": "ARP",
            "synced_to_ethos": False  # Would sync in production
        }
        self.attestations.append(attestation)
        
        # Update agent ARP score
        if tx["from"] in self.agents:
            agent = self.agents[tx["from"]]
            agent.arp_ratings.append({
                "rating": rating,
                "tx_hash": tx_hash,
                "feedback": feedback
            })
            agent.calculate_unified_score()
        
        return attestation
    
    def shared_slash(self, address: str, reason: str, severity: str = "medium") -> Dict:
        """
        Slash an agent - synchronized across ARP and Ethos
        
        In production, this would:
        1. Call ARP slashing function
        2. Submit slash to Ethos smart contract
        3. Update shared reputation database
        """
        if address not in self.agents:
            return {"error": "Agent not found"}
        
        agent = self.agents[address]
        
        # ARP-style slash
        slash_amount = agent.arp_stake * 0.5
        agent.arp_stake -= slash_amount
        agent.arp_ratings.append({
            "rating": 1,
            "tx_hash": "SHARED-SLASH",
            "feedback": f"Shared slash: {reason}"
        })
        
        # Ethos-style impact
        agent.ethos_slashes += 1
        agent.ethos_credibility_score -= 15
        
        # Record shared event
        slash_event = {
            "address": address,
            "reason": reason,
            "severity": severity,
            "arp_penalty": slash_amount,
            "ethos_penalty": 15,
            "timestamp": datetime.now().isoformat(),
            "platforms": ["ARP", "Ethos"]
        }
        self.shared_slashing_events.append(slash_event)
        
        # Recalculate unified score
        agent.calculate_unified_score()
        
        return {
            "success": True,
            "agent": agent.name,
            "arp_slashed": slash_amount,
            "ethos_slashed": 15,
            "new_unified_score": agent.unified_score,
            "new_tier": agent.unified_tier
        }
    
    def query_ethos_api(self, eth_address: str) -> Dict:
        """
        Query Ethos API for credibility score
        
        In production, this would:
        1. Call Ethos API endpoint
        2. Parse response
        3. Return structured data
        
        For demo, we simulate the response
        """
        if eth_address in [a.eth_address for a in self.agents.values() if a.eth_address]:
            agent = next(a for a in self.agents.values() if a.eth_address == eth_address)
            return {
                "address": eth_address,
                "credibility_score": agent.ethos_credibility_score,
                "wallet_age": agent.ethos_wallet_age,
                "vouches": agent.ethos_vouches,
                "reviews": {
                    "positive": agent.ethos_positive_reviews,
                    "negative": agent.ethos_negative_reviews
                },
                "slashes": agent.ethos_slashes,
                "sybil_risk": agent.ethos_sybil_risk,
                "attestations": agent.ethos_attestations,
                "credible_vouchers": agent.ethos_credible_vouchers
            }
        
        # Return default for unknown
        return {
            "address": eth_address,
            "credibility_score": 50.0,  # Default
            "wallet_age": 0,
            "vouches": 0,
            "reviews": {"positive": 0, "negative": 0},
            "slashes": 0,
            "sybil_risk": 0.5,  # Unknown = medium risk
            "attestations": 0,
            "credible_vouchers": 0
        }
    
    def get_trust_score(self, address: str, show_details: bool = False) -> Dict:
        """Get unified trust score for an agent"""
        if address not in self.agents:
            return {"error": "Agent not found"}
        
        agent = self.agents[address]
        return agent.to_dict(include_all=show_details)
    
    def get_all_agents(self, sort_by: str = "unified_score") -> List[Dict]:
        """Get all agents sorted by criteria"""
        agents_list = [a.to_dict() for a in self.agents.values()]
        if sort_by == "unified_score":
            agents_list.sort(key=lambda x: x["unified_score"], reverse=True)
        elif sort_by == "arp_score":
            agents_list.sort(key=lambda x: x["arp_score"], reverse=True)
        elif sort_by == "ethos_score":
            agents_list.sort(key=lambda x: x["ethos_score"], reverse=True)
        return agents_list
    
    def get_shared_leaderboard(self) -> List[Dict]:
        """Get unified trust leaderboard"""
        return self.get_all_agents(sort_by="unified_score")


class ARPxEthosDemo:
    """Demonstrate ARP x Ethos integration"""
    
    def __init__(self):
        self.integration = ARPxEthosIntegration("ARP-Ethos-Demo")
    
    def setup_demo_agents(self):
        """Create demo agents with ARP + Ethos profiles"""
        print("\n" + "="*60)
        print("🏗️  SETUP: Creating Agents with ARP + Ethos Profiles")
        print("="*60)
        
        # Agent 1: Established crypto OG
        agent1 = self.integration.register_agent(
            name="CryptoKing-OG",
            address="0x" + uuid.uuid4().hex[:40],
            eth_address="0x1111111111111111111111111111111111111111",
            arp_stake=100.0,
            ethos_wallet_age=5.0,  # 5 years
            ethos_vouches=50,
            ethos_positive_reviews=100,
            ethos_negative_reviews=2,
            ethos_slashes=0,
            ethos_attestations=25,
            ethos_credible_vouchers=20,
            ethos_sybil_risk=0.01  # Very low risk
        )
        
        # Agent 2: New AI agent with good track record
        agent2 = self.integration.register_agent(
            name="Agent-Genius",
            address="0x" + uuid.uuid4().hex[:40],
            eth_address="0x2222222222222222222222222222222222222222",
            arp_stake=50.0,
            ethos_wallet_age=1.0,
            ethos_vouches=10,
            ethos_positive_reviews=25,
            ethos_negative_reviews=1,
            ethos_slashes=0,
            ethos_attestations=8,
            ethos_credible_vouchers=5,
            ethos_sybil_risk=0.1
        )
        
        # Agent 3: Suspected scammer
        agent3 = self.integration.register_agent(
            name="Shady-Scammer",
            address="0x" + uuid.uuid4().hex[:40],
            eth_address="0x3333333333333333333333333333333333333333",
            arp_stake=10.0,
            ethos_wallet_age=0.1,  # Very new
            ethos_vouches=2,
            ethos_positive_reviews=5,
            ethos_negative_reviews=15,
            ethos_slashes=3,
            ethos_attestations=1,
            ethos_credible_vouchers=0,
            ethos_sybil_risk=0.8  # High risk
        )
        
        # Agent 4: Fresh newcomer
        agent4 = self.integration.register_agent(
            name="Newcomer-Bob",
            address="0x" + uuid.uuid4().hex[:40],
            eth_address="0x4444444444444444444444444444444444444444",
            arp_stake=5.0,
            ethos_wallet_age=0.0,
            ethos_vouches=0,
            ethos_positive_reviews=0,
            ethos_negative_reviews=0,
            ethos_slashes=0,
            ethos_attestations=0,
            ethos_credible_vouchers=0,
            ethos_sybil_risk=0.5
        )
        
        print(f"\n✅ Registered 4 agents:")
        for agent in [agent1, agent2, agent3, agent4]:
            print(f"   • {agent.name}: {agent.unified_tier} ({agent.unified_score:.1f})")
        
        return agent1, agent2, agent3, agent4
    
    def demo_unified_scoring(self):
        """Demonstrate unified scoring"""
        print("\n" + "="*60)
        print("📊 UNIFIED SCORING: ARP + Ethos Combined")
        print("="*60)
        
        agents = self.integration.get_shared_leaderboard()
        
        print(f"\n{'Rank':<6}{'Agent':<20}{'ARP':<10}{'Ethos':<10}{'Unified':<10}{'Tier'}")
        print("-" * 60)
        
        for i, agent in enumerate(agents, 1):
            print(f"{i:<6}{agent['name']:<20}{agent['arp_score']:<10.1f}{agent['ethos_score']:<10.1f}{agent['unified_score']:<10.1f}{agent['unified_tier']}")
        
        return agents
    
    def demo_shared_slashing(self):
        """Demonstrate shared slashing between systems"""
        print("\n" + "="*60)
        print("⚔️  SHARED SLASHING: Cross-Platform Accountability")
        print("="*60)
        
        # Find the scammer
        scammer = None
        for addr, agent in self.integration.agents.items():
            if "Shady" in agent.name:
                scammer = agent
                break
        
        if scammer:
            print(f"\n🚫 Detecting bad actor: {scammer.name}")
            print(f"   Before slash: {scammer.unified_tier} ({scammer.unified_score:.1f})")
            
            # Perform shared slash
            result = self.integration.shared_slash(
                scammer.address,
                reason="Multiple failed transactions reported",
                severity="high"
            )
            
            print(f"\n⚔️  SHARED SLASH EXECUTED:")
            print(f"   ARP penalty: {result['arp_slashed']:.1f} USDC")
            print(f"   Ethos penalty: {result['ethos_slashed']:.1f} credibility")
            print(f"   New unified score: {result['new_unified_score']:.1f}")
            print(f"   New tier: {result['new_tier']}")
            print(f"\n   ✅ Agent now flagged in BOTH ARP and Ethos!")
        
        return scammer
    
    def demo_ethos_query(self):
        """Demo querying Ethos API"""
        print("\n" + "="*60)
        print("🔍 ETHOS API INTEGRATION")
        print("="*60)
        
        # Query each agent's Ethos profile
        for addr, agent in self.integration.agents.items():
            if agent.eth_address:
                print(f"\n📡 Querying Ethos for {agent.name}:")
                ethos_data = self.integration.query_ethos_api(agent.eth_address)
                
                print(f"   Wallet Age: {ethos_data['wallet_age']} years")
                print(f"   Vouches: {ethos_data['vouches']}")
                print(f"   Reviews: +{ethos_data['reviews']['positive']} / -{ethos_data['reviews']['negative']}")
                print(f"   Slashes: {ethos_data['slashes']}")
                print(f"   Sybil Risk: {ethos_data['sybil_risk']:.0%}")
                print(f"   Credibility Score: {ethos_data['credibility_score']:.1f}")
    
    def demo_transactions(self):
        """Demo transaction with attestations"""
        print("\n" + "="*60)
        print("💸 TRANSACTION & ATTESTATION FLOW")
        print("="*60)
        
        agents = list(self.integration.agents.values())
        
        # Transaction 1: CryptoKing pays Agent-Genius
        tx1 = self.integration.submit_transaction(
            agents[0].address,  # From CryptoKing
            agents[1].address,  # To Agent-Genius
            25.0
        )
        print(f"\n💰 Transaction: {tx1['tx_hash'][:20]}...")
        
        # Attest
        att1 = self.integration.attest_transaction(
            tx1['tx_hash'],
            rating=5,
            feedback="Excellent AI agent service!",
            attest_type="completed"
        )
        print(f"   ⭐ Rating: 5/5 - Agent-Genius reputation boosted!")
        
        # Transaction 2: Shady tries to transact
        tx2 = self.integration.submit_transaction(
            agents[2].address,
            agents[1].address,
            10.0
        )
        att2 = self.integration.attest_transaction(
            tx2['tx_hash'],
            rating=1,
            feedback="Never delivered. Scam!",
            attest_type="failed"
        )
        print(f"\n💰 Transaction: {tx2['tx_hash'][:20]}...")
        print(f"   ⭐ Rating: 1/5 - Flagged!")
    
    def run_full_demo(self):
        """Run complete demo"""
        print("="*60)
        print("🚀 ARP x ETHOS INTEGRATION DEMO v1.0")
        print("   Unified Trust for Agent Economy")
        print("="*60)
        
        # Run all demos
        self.setup_demo_agents()
        self.demo_ethos_query()
        self.demo_transactions()
        self.demo_unified_scoring()
        self.demo_shared_slashing()
        
        # Final leaderboard
        print("\n" + "="*60)
        print("🏆 FINAL LEADERBOARD")
        print("="*60)
        agents = self.integration.get_shared_leaderboard()
        for i, agent in enumerate(agents, 1):
            print(f"{i}. {agent['name']}: {agent['unified_tier']} ({agent['unified_score']:.1f})")
        
        print("\n" + "="*60)
        print("💡 KEY INSIGHT")
        print("="*60)
        print("""
   ARP x Ethos = Ultimate Trust Layer
   
   ✓ Combines agent reputation with human credibility
   ✓ Shared slashing across platforms
   ✓ Cross-referenced trust scores
   ✓ Unified leaderboard
   
   This is the infrastructure the agent economy needs!
        """)


def main():
    demo = ARPxEthosDemo()
    demo.run_full_demo()


if __name__ == "__main__":
    main()
