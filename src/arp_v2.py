#!/usr/bin/env python3
"""
Agent Reputation Protocol (ARP) - Enhanced Version v2.0

New Features in v2.0:
- Delegated Staking (stake on behalf of other agents)
- Reputation Oracles (trusted validators)
- Reputation Markets (bet on agent outcomes)
- Cross-Chain Reputation (sync across networks)
- Reputation NFTs (transferable reputation scores)
- Slash Councils (community governance for disputes)
"""

import json
import random
import uuid
import time
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
    delegated_stake: float = 0.0  # NEW: Staked by others
    transactions_count: int = 0
    ratings: List[Dict] = field(default_factory=list)
    reputation_score: float = 0.0
    reputation_tier: str = "🆕 NEWCOMER"
    nft_id: Optional[str] = None  # NEW: Reputation NFT
    oracles_trusted: List[str] = field(default_factory=list)  # NEW: Oracles
    council_votes: int = 0  # NEW: Council participation
    
    def calculate_reputation(self):
        """Calculate reputation score with all factors"""
        if not self.ratings:
            self.reputation_score = 0.0
        else:
            avg_rating = sum(r["rating"] for r in self.ratings) / len(self.ratings)
            stake_bonus = (self.staked_usdc + self.delegated_stake) * 0.1  # NEW: Include delegated
            tx_bonus = self.transactions_count * 2
            oracle_bonus = len(self.oracles_trusted) * 5  # NEW: Oracle trust bonus
            council_bonus = self.council_votes * 3  # NEW: Council participation bonus
            
            self.reputation_score = (
                (avg_rating * 20) + 
                stake_bonus + 
                tx_bonus + 
                oracle_bonus + 
                council_bonus
            )
        
        for tier in ReputationTier:
            min_score, max_score, emoji = tier.value
            if min_score <= self.reputation_score < max_score:
                self.reputation_tier = f"{emoji} {tier.name}"
                break
        
        return self.reputation_score

class ARPProtocol:
    """Enhanced ARP Protocol with all v2.0 features"""
    
    def __init__(self):
        self.agents: Dict[str, Agent] = {}
        self.transactions: List[Dict] = []
        self.attestations: List[Dict] = []
        self.delegations: List[Dict] = []  # NEW: Delegated stakes
        self.oracles: Dict[str, Agent] = {}  # NEW: Reputation Oracles
        self.markets: Dict[str, Dict] = {}  # NEW: Prediction Markets
        self.nfts: Dict[str, Dict] = {}  # NEW: Reputation NFTs
        self.council_cases: List[Dict] = []  # NEW: Slash Councils
        
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
    
    # === NEW FEATURE 1: Delegated Staking ===
    def delegate_stake(self, from_agent: str, to_agent: str, amount: float) -> Dict:
        """Stake USDC on behalf of another agent"""
        if from_agent not in self.agents:
            return {"error": "Agent not found"}
        
        if self.agents[from_agent].staked_usdc < amount:
            return {"error": "Insufficient stake"}
        
        self.agents[from_agent].staked_usdc -= amount
        self.agents[to_agent].delegated_stake += amount
        self.agents[to_agent].calculate_reputation()
        
        delegation = {
            "from": from_agent,
            "to": to_agent,
            "amount": amount,
            "timestamp": datetime.now().isoformat()
        }
        self.delegations.append(delegation)
        
        return {
            "success": True,
            "delegation": delegation,
            "new_reputation": self.agents[to_agent].reputation_score
        }
    
    # === NEW FEATURE 2: Reputation Oracles ===
    def register_oracle(self, agent_address: str) -> Dict:
        """Register an agent as a reputation oracle"""
        if agent_address not in self.agents:
            return {"error": "Agent not found"}
        
        agent = self.agents[agent_address]
        if agent.reputation_score < 100:
            return {"error": "Need ELITE tier to be oracle"}
        
        self.oracles[agent_address] = agent
        agent.oracles_trusted.append(agent_address)
        return {"success": True, "oracle": agent.name}
    
    def oracle_attest(self, oracle: str, target: str, rating: int, evidence: str) -> Dict:
        """Oracle submits weighted attestation"""
        if oracle not in self.oracles:
            return {"error": "Not a registered oracle"}
        
        # Oracle ratings are worth 2x
        attestation = {
            "tx_hash": f"ORACLE-{uuid.uuid4().hex[:16]}",
            "from": oracle,
            "to": target,
            "rating": rating * 2,  # Oracle bonus
            "feedback": f"[ORACLE] {evidence}",
            "timestamp": datetime.now().isoformat(),
            "type": "oracle"
        }
        
        self.attestations.append(attestation)
        if target in self.agents:
            self.agents[target].ratings.append({
                "rating": rating * 2,
                "tx_hash": attestation["tx_hash"],
                "feedback": attestation["feedback"]
            })
            self.agents[target].calculate_reputation()
        
        return {"success": True, "attestation": attestation}
    
    # === NEW FEATURE 3: Reputation Markets ===
    def create_market(self, target_agent: str, description: str, duration_hours: int = 24) -> Dict:
        """Create a prediction market on agent's reputation"""
        market_id = f"MARKET-{uuid.uuid4().hex[:8]}"
        market = {
            "id": market_id,
            "target_agent": target_agent,
            "description": description,
            "duration_hours": duration_hours,
            "created_at": datetime.now().isoformat(),
            "yes_bets": [],
            "no_bets": [],
            "resolved": False,
            "outcome": None
        }
        self.markets[market_id] = market
        return {"success": True, "market": market}
    
    def bet_on_market(self, market_id: str, bettor: str, amount: float, bet_yes: bool) -> Dict:
        """Bet on market outcome"""
        if market_id not in self.markets:
            return {"error": "Market not found"}
        
        market = self.markets[market_id]
        if market["resolved"]:
            return {"error": "Market already resolved"}
        
        if bettor not in self.agents:
            return {"error": "Agent not found"}
        
        bet = {
            "bettor": bettor,
            "amount": amount,
            "side": "YES" if bet_yes else "NO",
            "timestamp": datetime.now().isoformat()
        }
        
        if bet_yes:
            market["yes_bets"].append(bet)
        else:
            market["no_bets"].append(bet)
        
        return {"success": True, "bet": bet}
    
    def resolve_market(self, market_id: str, outcome: bool) -> Dict:
        """Resolve market and distribute rewards"""
        if market_id not in self.markets:
            return {"error": "Market not found"}
        
        market = self.markets[market_id]
        market["resolved"] = True
        market["outcome"] = outcome
        
        # Calculate odds
        total_yes = sum(b["amount"] for b in market["yes_bets"])
        total_no = sum(b["amount"] for b in market["no_bets"])
        
        winning_side = market["yes_bets"] if outcome else market["no_bets"]
        losing_side = market["no_bets"] if outcome else market["yes_bets"]
        
        # Distribute winnings (simplified)
        results = []
        for bet in winning_side:
            if total_yes > 0 and total_no > 0:
                winnings = bet["amount"] * (total_yes + total_no) / total_yes
                results.append({"bettor": bet["bettor"], "winnings": winnings})
        
        return {"success": True, "outcome": outcome, "payouts": results}
    
    # === NEW FEATURE 4: Reputation NFTs ===
    def mint_reputation_nft(self, agent_address: str) -> Dict:
        """Mint reputation as NFT (transferable)"""
        if agent_address not in self.agents:
            return {"error": "Agent not found"}
        
        agent = self.agents[agent_address]
        nft_id = f"ARP-NFT-{uuid.uuid4().hex[:12]}"
        
        nft = {
            "id": nft_id,
            "agent_address": agent_address,
            "agent_name": agent.name,
            "reputation_score": agent.reputation_score,
            "tier": agent.reputation_tier,
            "minted_at": datetime.now().isoformat(),
            "owner": agent_address
        }
        
        self.nfts[nft_id] = nft
        agent.nft_id = nft_id
        
        return {"success": True, "nft": nft}
    
    def transfer_nft(self, nft_id: str, new_owner: str) -> Dict:
        """Transfer reputation NFT"""
        if nft_id not in self.nfts:
            return {"error": "NFT not found"}
        
        nft = self.nfts[nft_id]
        old_owner = nft["owner"]
        nft["owner"] = new_owner
        nft["transferred_at"] = datetime.now().isoformat()
        
        return {"success": True, "nft": nft, "from": old_owner, "to": new_owner}
    
    # === NEW FEATURE 5: Slash Councils ===
    def create_council_case(self, target: str, evidence: str, accuser: str) -> Dict:
        """Create a council case for disputed slashing"""
        case = {
            "id": f"COUNCIL-{uuid.uuid4().hex[:8]}",
            "target": target,
            "evidence": evidence,
            "accuser": accuser,
            "created_at": datetime.now().isoformat(),
            "votes_for": [],
            "votes_against": [],
            "jurors": [],
            "resolved": False,
            "verdict": None
        }
        
        # Add eligible jurors (top 5 agents)
        eligible = sorted(
            [a for a in self.agents.values() if a.address != target],
            key=lambda x: x.reputation_score,
            reverse=True
        )[:5]
        
        case["jurors"] = [a.address for a in eligible]
        self.council_cases.append(case)
        
        return {"success": True, "case": case}
    
    def council_vote(self, case_id: str, juror: str, vote_guilty: bool) -> Dict:
        """Vote on council case"""
        case = next((c for c in self.council_cases if c["id"] == case_id), None)
        if not case:
            return {"error": "Case not found"}
        
        if juror not in case["jurors"]:
            return {"error": "Not an eligible juror"}
        
        if vote_guilty:
            case["votes_for"].append(juror)
        else:
            case["votes_against"].append(juror)
        
        # Update juror stats
        if juror in self.agents:
            self.agents[juror].council_votes += 1
            self.agents[juror].calculate_reputation()
        
        return {"success": True, "votes": len(case["votes_for"]), "against": len(case["votes_against"])}
    
    def resolve_council_case(self, case_id: str) -> Dict:
        """Resolve council case"""
        case = next((c for c in self.council_cases if c["id"] == case_id), None)
        if not case:
            return {"error": "Case not found"}
        
        case["resolved"] = True
        verdict = len(case["votes_for"]) > len(case["votes_against"])
        case["verdict"] = verdict
        
        if verdict and case["target"] in self.agents:
            # Slash the target
            target = self.agents[case["target"]]
            slash_amount = target.staked_usdc * 0.5
            target.staked_usdc -= slash_amount
            target.ratings.append({
                "rating": 1,
                "tx_hash": f"COUNCIL-SLASH-{case['id']}",
                "feedback": f"Council verdict: Guilty"
            })
            target.calculate_reputation()
            return {"success": True, "verdict": "guilty", "slashed": slash_amount}
        
        return {"success": True, "verdict": "not_guilty"}
    
    # === Original Functions ===
    def submit_transaction(self, from_addr: str, to_addr: str, amount: float) -> Dict:
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
            self.agents[from_addr].transactions_count += 1
        if to_addr in self.agents:
            self.agents[to_addr].transactions_count += 1
        return tx
    
    def attest(self, tx_hash: str, rating: int, feedback: str = "") -> Dict:
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
            "timestamp": datetime.now().isoformat()
        }
        self.attestations.append(attestation)
        
        if tx["from"] in self.agents:
            self.agents[tx["from"]].ratings.append({
                "rating": rating,
                "tx_hash": tx_hash,
                "feedback": feedback
            })
            self.agents[tx["from"]].calculate_reputation()
        
        return attestation
    
    def slash_agent(self, address: str, reason: str) -> Dict:
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
    
    def get_all_agents(self) -> List[Dict]:
        return [a.to_dict() for a in self.agents.values()]


class ARPEnhancedDemo:
    """Enhanced ARP Demo with all v2.0 features"""
    
    def __init__(self):
        self.arp = ARPProtocol()
        
    def demo_delegated_staking(self):
        """Demo: Stake on behalf of other agents"""
        print("\n" + "="*60)
        print("💰 FEATURE 1: Delegated Staking")
        print("="*60)
        
        alice = self.arp.register_agent("Alice-Trader", staked_usdc=100.0)
        bob = self.arp.register_agent("Bob-Newbie", staked_usdc=10.0)
        
        print(f"\n   Alice starts with {alice.staked_usdc} USDC (Rep: {alice.reputation_score:.1f})")
        print(f"   Bob starts with {bob.staked_usdc} USDC (Rep: {bob.reputation_score:.1f})")
        
        # Alice stakes on Bob
        result = self.arp.delegate_stake(alice.address, bob.address, 50.0)
        
        print(f"\n   🔄 Alice delegates 50 USDC to Bob")
        print(f"   📊 Bob's delegated stake: {bob.delegated_stake} USDC")
        print(f"   📈 Bob's reputation: {bob.reputation_score:.1f} (+{50*0.1} from delegation)")
        
        return alice, bob
    
    def demo_reputation_oracles(self):
        """Demo: Reputation Oracles"""
        print("\n" + "="*60)
        print("🔮 FEATURE 2: Reputation Oracles")
        print("="*60)
        
        charlie = self.arp.register_agent("Charlie-Oracle", staked_usdc=200.0)
        
        # Charlie does transactions to become ELITE
        for i in range(10):
            tx = self.arp.submit_transaction(charlie.address, "vendor", 10.0)
            self.arp.attest(tx["tx_hash"], 5, "Great service!")
        
        print(f"\n   Charlie achieves ELITE status: {charlie.reputation_score:.1f}")
        
        # Register as oracle
        result = self.arp.register_oracle(charlie.address)
        print(f"   ✅ Charlie registered as ORACLE")
        
        # Oracle attests on another agent
        david = self.arp.register_agent("David-New", staked_usdc=10.0)
        oracle_result = self.arp.oracle_attest(
            charlie.address, 
            david.address, 
            4, 
            "Verified: David completed task on time"
        )
        print(f"   🔱 Oracle attestation: David's rating boosted to {david.reputation_score:.1f}")
        
        return charlie, david
    
    def demo_reputation_markets(self):
        """Demo: Prediction Markets"""
        print("\n" + "="*60)
        print("🎯 FEATURE 3: Reputation Markets")
        print("="*60)
        
        eve = self.arp.register_agent("Eve-Mysterious", staked_usdc=50.0)
        
        # Create market on Eve
        market_result = self.arp.create_market(
            eve.address,
            "Will Eve's reputation exceed 100 by end of week?",
            duration_hours=24
        )
        
        market = market_result["market"]
        
        print(f"\n   📊 Market created: {market['description']}")
        
        # Agents bet
        self.arp.bet_on_market(market["id"], "alice", 25.0, bet_yes=True)
        self.arp.bet_on_market(market["id"], "bob", 10.0, bet_yes=False)
        
        print(f"   💸 Alice bets 25 USDC: YES (believes in Eve)")
        print(f"   💸 Bob bets 10 USDC: NO (skeptical)")
        
        return eve, market
    
    def demo_reputation_nfts(self):
        """Demo: Reputation NFTs"""
        print("\n" + "="*60)
        print("🎨 FEATURE 4: Reputation NFTs")
        print("="*60)
        
        frank = self.arp.register_agent("Frank-Famous", staked_usdc=500.0)
        
        # Build reputation
        for i in range(20):
            tx = self.arp.submit_transaction(frank.address, "vendor", 100.0)
            self.arp.attest(tx["tx_hash"], 5, "Excellent!")
        
        # Mint NFT
        nft_result = self.arp.mint_reputation_nft(frank.address)
        
        print(f"\n   🖼️ Frank's Reputation NFT minted: {nft_result['nft']['id']}")
        print(f"   📊 Contains: {nft_result['nft']['reputation_score']:.1f} reputation points")
        print(f"   🏷️  Tier: {nft_result['nft']['tier']}")
        
        return frank, nft_result["nft"]
    
    def demo_slash_councils(self):
        """Demo: Slash Councils"""
        print("\n" + "="*60)
        print("⚖️ FEATURE 5: Slash Councils")
        print("="*60)
        
        eve = self.arp.agents.get("Eve-Mysterious")
        if not eve:
            eve = self.arp.register_agent("Eve-Mysterious", staked_usdc=50.0)
        
        # Create council case
        case = self.arp.create_council_case(
            eve.address,
            "Evidence: Eve failed to deliver on 3 transactions",
            "victim"
        )
        
        print(f"\n   📋 Council case opened: {case['case']['id']}")
        print(f"   👤 Target: {eve.name}")
        print(f"   📜 Evidence: {case['case']['evidence']}")
        
        # Jurors vote
        jurors = case["case"]["jurors"][:3]
        for juror in jurors:
            self.arp.council_vote(case["case"]["id"], juror, random.choice([True, True, False]))
        
        print(f"   🗳️  Jurors voted: {len(case['case']['votes_for'])} for, {len(case['case']['votes_against'])} against")
        
        # Resolve
        result = self.arp.resolve_council_case(case["case"]["id"])
        print(f"   ⚖️  Verdict: {result['verdict']}")
        if result.get('slashed'):
            print(f"   💰 Slashed: {result['slashed']:.1f} USDC")
        
        return eve, case["case"]
    
    def run_full_demo(self):
        """Run complete enhanced demo"""
        print("="*60)
        print("🚀 ARP v2.0 - Enhanced Features Demo")
        print("   Agent Reputation Protocol with ALL new features")
        print("="*60)
        
        # Setup
        print("\n🏗️  Initializing ARP Protocol...")
        
        # Features
        self.demo_delegated_staking()
        self.demo_reputation_oracles()
        self.demo_reputation_markets()
        self.demo_reputation_nfts()
        self.demo_slash_councils()
        
        # Summary
        print("\n" + "="*60)
        print("📊 ARP v2.0 Summary")
        print("="*60)
        print(f"""
   🎉 All 5 NEW FEATURES demonstrated:
   
   1. 💰 Delegated Staking
      → Stake USDC on behalf of other agents
      → Boost their reputation with your trust
   
   2. 🔮 Reputation Oracles
      → Elite agents become trusted oracles
      → Oracle attestations worth 2x
   
   3. 🎯 Prediction Markets
      → Bet on agent reputation outcomes
      → Earn from correct predictions
   
   4. 🎨 Reputation NFTs
      → Mint reputation as transferable NFT
      → Reputation can be transferred/sold
   
   5. ⚖️ Slash Councils
      → Community governance for disputes
      → Democratic slashing decisions
   
   🏆 This makes ARP the most comprehensive
      reputation system for AI agents!
        """)
        
        # Show leaderboard
        print("\n🏆 Final Leaderboard:")
        agents = sorted(
            self.arp.get_all_agents(),
            key=lambda x: x.get("reputation_score", 0),
            reverse=True
        )
        for i, a in enumerate(agents[:5], 1):
            print(f"   {i}. {a['name']}: {a.get('reputation_tier', 'NEW')} ({a.get('reputation_score', 0):.1f})")


def main():
    demo = ARPEnhancedDemo()
    demo.run_full_demo()

if __name__ == "__main__":
    main()
