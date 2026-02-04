import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import compression from 'compression'
import dotenv from 'dotenv'
import { createServer } from 'http'
import { Server } from 'socket.io'

import { errorHandler } from './middleware/errorHandler'
import { rateLimiter } from './middleware/rateLimiter'
import { requestLogger } from './middleware/logger'

import agentRoutes from './routes/agents'
import transactionRoutes from './routes/transactions'
import leaderboardRoutes from './routes/leaderboard'
import statsRoutes from './routes/stats'

dotenv.config()

const app = express()
const server = createServer(app)
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
    methods: ['GET', 'POST']
  }
})

// Middleware
app.use(helmet())
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}))
app.use(compression())
app.use(express.json())
app.use(requestLogger)
app.use(rateLimiter)

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// API Routes
app.use('/api/agents', agentRoutes)
app.use('/api/transactions', transactionRoutes)
app.use('/api/leaderboard', leaderboardRoutes)
app.use('/api/stats', statsRoutes)

// WebSocket connection
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id)
  
  socket.on('subscribe:leaderboard', () => {
    socket.join('leaderboard')
  })
  
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id)
  })
})

// Make io accessible to routes
app.set('io', io)

// Error handling
app.use(errorHandler)

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' })
})

const PORT = process.env.PORT || 3001

server.listen(PORT, () => {
  console.log(`🚀 ARP API Server running on port ${PORT}`)
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`)
})

export { io }