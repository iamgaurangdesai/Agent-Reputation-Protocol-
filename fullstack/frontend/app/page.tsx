'use client'

import { useState } from 'react'
import { ConnectButton } from '@rainbow-me/rainbowkit'
import { useAccount, useContractRead, useContractWrite } from 'wagmi'
import { formatEther, parseEther } from 'viem'
import { AgentCard } from '@/components/agent-card'
import { ScoreCalculator } from '@/components/score-calculator'
import { Leaderboard } from '@/components/leaderboard'
import { ARP_CONTRACT_ABI, ARP_CONTRACT_ADDRESS } from '@/lib/contracts'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'

export default function Home() {
  const { address, isConnected } = useAccount()
  const [agentName, setAgentName] = useState('')
  const [stakeAmount, setStakeAmount] = useState('')

  // Read agent data
  const { data: agentData } = useContractRead({
    address: ARP_CONTRACT_ADDRESS,
    abi: ARP_CONTRACT_ABI,
    functionName: 'getAgent',
    args: address ? [address] : undefined,
    enabled: !!address,
  })

  // Register agent
  const { write: registerAgent, isLoading: isRegistering } = useContractWrite({
    address: ARP_CONTRACT_ADDRESS,
    abi: ARP_CONTRACT_ABI,
    functionName: 'registerAgent',
  })

  const handleRegister = () => {
    if (!agentName || !stakeAmount) return
    registerAgent({
      args: [agentName, parseEther(stakeAmount)],
      value: parseEther(stakeAmount),
    })
  }

  return (
    <main className="min-h-screen bg-gradient-to-b from-background to-muted">
      {/* Header */}
      <header className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container flex h-16 items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary text-primary-foreground font-bold text-xl">
              ⌘
            </div>
            <span className="font-bold text-lg">ARP</span>
          </div>
          <ConnectButton />
        </div>
      </header>

      {/* Hero */}
      <section className="container py-20">
        <div className="mx-auto max-w-3xl text-center">
          <h1 className="text-5xl font-bold tracking-tight sm:text-6xl md:text-7xl">
            Trust for{' '}
            <span className="text-primary">AI Agents</span>
          </h1>
          <p className="mt-6 text-xl text-muted-foreground">
            On-chain reputation system for autonomous AI agents. 
            Build reputation, prevent fraud, enable safe commerce.
          </p>
          
          {/* Stats */}
          <div className="mt-10 grid grid-cols-2 gap-4 sm:grid-cols-4">
            <StatCard value="2,847" label="Agents" />
            <StatCard value="$12.4M" label="Staked" />
            <StatCard value="156K" label="TXs" />
            <StatCard value="99.7%" label="Uptime" />
          </div>
        </div>
      </section>

      {/* Main Content */}
      <section className="container pb-20">
        <Tabs defaultValue="leaderboard" className="mx-auto max-w-4xl">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="leaderboard">Leaderboard</TabsTrigger>
            <TabsTrigger value="register">Register Agent</TabsTrigger>
            <TabsTrigger value="calculate">Calculate Score</TabsTrigger>
          </TabsList>
          
          <TabsContent value="leaderboard" className="mt-6">
            <Leaderboard />
          </TabsContent>
          
          <TabsContent value="register" className="mt-6">
            <div className="rounded-lg border bg-card p-6">
              <h2 className="text-2xl font-bold mb-4">Register Your Agent</h2>
              {isConnected ? (
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium">Agent Name</label>
                    <Input
                      value={agentName}
                      onChange={(e) => setAgentName(e.target.value)}
                      placeholder="e.g., CryptoKing"
                    />
                  </div>
                  <div>
                    <label className="text-sm font-medium">Stake Amount (ETH)</label>
                    <Input
                      value={stakeAmount}
                      onChange={(e) => setStakeAmount(e.target.value)}
                      placeholder="0.1"
                      type="number"
                      step="0.01"
                    />
                  </div>
                  <Button 
                    onClick={handleRegister}
                    disabled={isRegistering || !agentName || !stakeAmount}
                    className="w-full"
                  >
                    {isRegistering ? 'Registering...' : 'Register Agent'}
                  </Button>
                </div>
              ) : (
                <div className="text-center py-8">
                  <p className="text-muted-foreground mb-4">Connect your wallet to register</p>
                  <ConnectButton />
                </div>
              )}
            </div>
          </TabsContent>
          
          <TabsContent value="calculate" className="mt-6">
            <ScoreCalculator />
          </TabsContent>
        </Tabs>
      </section>
    </main>
  )
}

function StatCard({ value, label }: { value: string; label: string }) {
  return (
    <div className="rounded-lg border bg-card p-4 text-center">
      <div className="text-2xl font-bold text-primary">{value}</div>
      <div className="text-xs text-muted-foreground uppercase tracking-wider">{label}</div>
    </div>
  )
}