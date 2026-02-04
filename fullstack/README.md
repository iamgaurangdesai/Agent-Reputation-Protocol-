# ARP Full Stack Architecture

## Overview
Production-ready full stack application for Agent Reputation Protocol.

## Stack

### Frontend (Next.js 14)
- **Framework:** Next.js 14 with App Router
- **Styling:** Tailwind CSS + shadcn/ui
- **State:** React Query + Zustand
- **Web3:** wagmi + viem
- **Auth:** NextAuth.js

### Backend (Node.js)
- **Framework:** Express.js
- **Database:** PostgreSQL + Prisma
- **Cache:** Redis
- **Queue:** BullMQ
- **Real-time:** Socket.io

### Database (PostgreSQL)
- **ORM:** Prisma
- **Migrations:** Prisma Migrate
- **Seeding:** Prisma Seed

## Project Structure

```
fullstack/
├── frontend/          # Next.js app
├── backend/           # Express API
├── database/          # Prisma schema + migrations
├── docker-compose.yml # Local dev setup
└── README.md
```

## Quick Start

```bash
# 1. Start database
docker-compose up -d

# 2. Setup backend
cd backend
npm install
npm run db:migrate
npm run dev

# 3. Setup frontend (new terminal)
cd frontend
npm install
npm run dev
```

## Environment Variables

### Frontend (.env.local)
```
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_CONTRACT_ADDRESS=0x...
NEXTAUTH_SECRET=your-secret
NEXTAUTH_URL=http://localhost:3000
```

### Backend (.env)
```
DATABASE_URL=postgresql://user:pass@localhost:5432/arp
REDIS_URL=redis://localhost:6379
PORT=3001
JWT_SECRET=your-jwt-secret
```
