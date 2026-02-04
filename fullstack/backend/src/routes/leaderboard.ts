import { Router } from 'express'
import { PrismaClient } from '@prisma/client'

const router = Router()
const prisma = new PrismaClient()

// GET /api/leaderboard - Get top agents by score
router.get('/', async (req, res, next) => {
  try {
    const { 
      timeframe = 'all', // all, week, month
      limit = 100 
    } = req.query

    let dateFilter = {}
    if (timeframe === 'week') {
      dateFilter = { createdAt: { gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } }
    } else if (timeframe === 'month') {
      dateFilter = { createdAt: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } }
    }

    const agents = await prisma.agent.findMany({
      where: {
        isActive: true,
        ...dateFilter
      },
      orderBy: { unifiedScore: 'desc' },
      take: Number(limit),
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
        averageRating: true,
        createdAt: true
      }
    })

    // Add rank
    const rankedAgents = agents.map((agent, index) => ({
      ...agent,
      rank: index + 1
    }))

    res.json({
      leaderboard: rankedAgents,
      timeframe,
      generatedAt: new Date().toISOString()
    })
  } catch (error) {
    next(error)
  }
})

// GET /api/leaderboard/tiers - Get distribution by tier
router.get('/tiers', async (req, res, next) => {
  try {
    const distribution = await prisma.agent.groupBy({
      by: ['tier'],
      where: { isActive: true },
      _count: { tier: true },
      _avg: { unifiedScore: true }
    })

    res.json(distribution)
  } catch (error) {
    next(error)
  }
})

export default router