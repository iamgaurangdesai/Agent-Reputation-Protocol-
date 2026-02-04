import { Router } from 'express'
import { PrismaClient } from '@prisma/client'
import { z } from 'zod'
import { ethers } from 'ethers'

const router = Router()
const prisma = new PrismaClient()

// Validation schemas
const registerAgentSchema = z.object({
  walletAddress: z.string().regex(/^0x[a-fA-F0-9]{40}$/),
  name: z.string().min(3).max(50),
  description: z.string().max(500).optional(),
  stakeAmount: z.string() // ETH as string
})

// GET /api/agents - List agents with filtering
router.get('/', async (req, res, next) => {
  try {
    const { 
      tier, 
      sortBy = 'unifiedScore', 
      order = 'desc',
      limit = 20,
      offset = 0 
    } = req.query

    const where: any = { isActive: true }
    if (tier) where.tier = tier

    const agents = await prisma.agent.findMany({
      where,
      orderBy: { [sortBy as string]: order },
      take: Number(limit),
      skip: Number(offset),
      select: {
        id: true,
        walletAddress: true,
        name: true,
        avatarUrl: true,
        unifiedScore: true,
        arpScore: true,
        ethosScore: true,
        tier: true,
        totalStaked: true,
        transactionCount: true,
        isVerified: true,
        createdAt: true
      }
    })

    res.json({
      agents,
      pagination: {
        limit: Number(limit),
        offset: Number(offset),
        total: await prisma.agent.count({ where })
      }
    })
  } catch (error) {
    next(error)
  }
})

// GET /api/agents/:wallet - Get single agent
router.get('/:walletAddress', async (req, res, next) => {
  try {
    const { walletAddress } = req.params

    const agent = await prisma.agent.findUnique({
      where: { walletAddress: walletAddress.toLowerCase() },
      include: {
        transactions: {
          take: 10,
          orderBy: { createdAt: 'desc' },
          include: { rating: true }
        },
        delegators: {
          where: { isActive: true },
          include: { delegator: true }
        }
      }
    })

    if (!agent) {
      return res.status(404).json({ error: 'Agent not found' })
    }

    res.json(agent)
  } catch (error) {
    next(error)
  }
})

// POST /api/agents - Register new agent
router.post('/', async (req, res, next) => {
  try {
    const data = registerAgentSchema.parse(req.body)
    
    // Check if agent already exists
    const existing = await prisma.agent.findUnique({
      where: { walletAddress: data.walletAddress.toLowerCase() }
    })
    
    if (existing) {
      return res.status(409).json({ error: 'Agent already registered' })
    }

    // Calculate initial score based on stake
    const stakeAmount = parseFloat(data.stakeAmount)
    const initialScore = Math.min(Math.floor(stakeAmount * 10), 25)

    const agent = await prisma.agent.create({
      data: {
        walletAddress: data.walletAddress.toLowerCase(),
        name: data.name,
        description: data.description,
        totalStaked: stakeAmount,
        unifiedScore: initialScore,
        arpScore: initialScore,
        tier: initialScore >= 25 ? 'TRUSTED' : 'NEWCOMER'
      }
    })

    // Emit event for real-time updates
    const io = req.app.get('io')
    io.to('leaderboard').emit('agent:registered', agent)

    res.status(201).json(agent)
  } catch (error) {
    next(error)
  }
})

// GET /api/agents/:wallet/stats - Get agent statistics
router.get('/:walletAddress/stats', async (req, res, next) => {
  try {
    const { walletAddress } = req.params

    const stats = await prisma.$queryRaw`
      SELECT 
        COUNT(*) as total_transactions,
        AVG(r.score) as average_rating,
        COUNT(CASE WHEN r.score > 0 THEN 1 END) as positive_ratings,
        COUNT(CASE WHEN r.score < 0 THEN 1 END) as negative_ratings
      FROM transactions t
      LEFT JOIN ratings r ON t.id = r.transaction_id
      WHERE t.to_agent_id = (
        SELECT id FROM agents WHERE wallet_address = ${walletAddress.toLowerCase()}
      )
    `

    res.json(stats[0])
  } catch (error) {
    next(error)
  }
})

export default router