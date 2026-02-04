#!/usr/bin/env python3
"""
Rentahuman x ARP Combined Demo
Shows how human verification + agent reputation create unified trust
"""

import asyncio
import json
from dataclasses import dataclass
from typing import Optional

@dataclass
class RentahumanResult:
    verified: bool
    score: int
    verified_at: str
    tier: str

@dataclass
class ARPResult:
    arp_score: int
    tier: str
    stake: int
    transactions: int

@dataclass
class CombinedTrust:
    wallet: str
    human_status: RentahumanResult
    arp_status: ARPResult
    trust_level: str
    color: str
    recommendation: str

# Simulated Rentahuman API
async def check_rentahuman(wallet: str) -> RentahumanResult:
    """Check human verification status"""
    # Simulated - in production, call actual API
    hash_val = sum(ord(c) for c in wallet)
    score = (hash_val % 100)
    verified = score >= 50
    
    tiers = {
        (80, 100): "Diamond",
        (60, 79): "Gold", 
        (40, 59): "Silver",
        (0, 39): "Bronze"
    }
    
    tier = "Bronze"
    for range_val, name in tiers.items():
        if range_val[0] <= score <= range_val[1]:
            tier = name
            break
    
    return RentahumanResult(
        verified=verified,
        score=score,
        verified_at="2026-01-15" if verified else "N/A",
        tier=tier
    )

# Simulated ARP API  
async def check_arp(wallet: str) -> ARPResult:
    """Check agent reputation on ARP"""
    # Simulated - in production, call contract
    hash_val = sum(ord(c) for c in wallet)
    base_score = (hash_val % 100)
    
    arp_score = base_score * 2
    transactions = base_score * 3
    stake = base_score * 10
    
    if arp_score >= 100:
        tier = "legendary"
    elif arp_score >= 75:
        tier = "elite"
    elif arp_score >= 50:
        tier = "established"
    elif arp_score >= 25:
        tier = "trusted"
    else:
        tier = "newcomer"
    
    return ARPResult(
        arp_score=arp_score,
        tier=tier,
        stake=stake,
        transactions=transactions
    )

def calculate_combined_trust(human: RentahumanResult, arp: ARPResult) -> tuple[str, str, str]:
    """Calculate combined trust level"""
    if human.verified and arp.arp_score >= 75:
        return "🟢 TRUSTED", "green", "Full access. Human verified with strong reputation."
    elif human.verified:
        return "🟡 CAUTION", "yellow", "Standard access. Human verified, reputation developing."
    elif arp.arp_score >= 100:
        return "🟠 SUSPICIOUS", "orange", "Require verification. High rep but no human proof."
    else:
        return "🔴 BLOCK", "red", "Access denied. Insufficient trust signals."

async def check_combined_trust(wallet: str) -> CombinedTrust:
    """Check both and return combined trust"""
    human = await check_rentahuman(wallet)
    arp = await check_arp(wallet)
    
    trust_level, color, recommendation = calculate_combined_trust(human, arp)
    
    return CombinedTrust(
        wallet=wallet,
        human_status=human,
        arp_status=arp,
        trust_level=trust_level,
        color=color,
        recommendation=recommendation
    )

async def demo():
    """Run demo with sample wallets"""
    print("=" * 60)
    print("  RENTAHUMAN x ARP INTEGRATION DEMO")
    print("  Unified Trust for Humans + Agents")
    print("=" * 60)
    print()
    
    sample_wallets = [
        "0x1234567890abcdef1234567890abcdef12345678",  # Good human + good agent
        "0xabcdef1234567890abcdef1234567890abcdef12",  # Verified human only
        "0x5555555555555555555555555555555555555555",  # Agent only (high rep)
        "0x9999999999999999999999999999999999999999",  # Neither (suspicious)
    ]
    
    for wallet in sample_wallets:
        result = await check_combined_trust(wallet)
        
        print(f"Wallet: {wallet[:10]}...{wallet[-8:]}")
        print("-" * 50)
        print(f"  🤝 RENTAHUMAN:")
        print(f"     Verified: {'✅' if result.human_status.verified else '❌'}")
        print(f"     Score: {result.human_status.score}/100 ({result.human_status.tier})")
        print()
        print(f"  🤖 ARP:")
        print(f"     Score: {result.arp_status.arp_score} ({result.arp_status.tier})")
        print(f"     Stake: {result.arp_status.stake} USDC")
        print(f"     TXs: {result.arp_status.transactions}")
        print()
        print(f"  🎯 COMBINED TRUST: {result.trust_level}")
        print(f"  💡 {result.recommendation}")
        print()
        print("=" * 60)
        print()

def main():
    """Entry point"""
    asyncio.run(demo())

if __name__ == "__main__":
    main()
