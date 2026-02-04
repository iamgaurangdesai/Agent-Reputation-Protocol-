# 🚀 Production Deployment Guide

## Quick Deploy Checklist

### 1. Environment Setup

Create `.env.production` files:

**Frontend (.env.production)**
```
NEXT_PUBLIC_API_URL=https://api.arp.io
NEXT_PUBLIC_CONTRACT_ADDRESS=0x...
NEXT_PUBLIC_NETWORK=base
NEXTAUTH_SECRET=your-secret-here
NEXTAUTH_URL=https://arp.io
```

**Backend (.env.production)**
```
NODE_ENV=production
PORT=3001
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
JWT_SECRET=your-jwt-secret
CONTRACT_ADDRESS=0x...
RPC_URL=https://mainnet.base.org
```

### 2. Deploy to Vercel (Frontend)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy frontend
cd frontend
vercel --prod
```

**Vercel Settings:**
- Framework: Next.js
- Build Command: `npm run build`
- Output Directory: `.next`
- Environment Variables: Add all from .env.production

### 3. Deploy Backend (Railway/Render/Fly.io)

**Option A: Railway (Recommended)**
```bash
# Install Railway CLI
npm i -g @railway/cli

# Deploy
cd backend
railway login
railway init
railway up
```

**Option B: Render**
- Connect GitHub repo
- Set root directory: `fullstack/backend`
- Build command: `npm install && npm run build`
- Start command: `npm start`

### 4. Database (Neon/Supabase)

**Neon PostgreSQL:**
1. Create project at neon.tech
2. Get connection string
3. Run migrations: `npx prisma migrate deploy`
4. Seed data: `npm run db:seed`

### 5. Smart Contract (Base Mainnet)

**Deploy Contract:**
```bash
# Using Hardhat
npx hardhat run scripts/deploy.js --network baseMainnet

# Verify on Basescan
npx hardhat verify --network baseMainnet DEPLOYED_ADDRESS
```

### 6. Domain & SSL

**Vercel:** Auto SSL + Custom domain
**Cloudflare:** DNS + CDN + DDoS protection

Add DNS records:
```
A     arp.io     → Vercel IPs
CNAME api.arp.io → Railway/Render domain
```

### 7. Monitoring

**Sentry:** Error tracking
```bash
npm install @sentry/nextjs @sentry/node
```

**LogRocket:** Session replay
```bash
npm install logrocket
```

**Uptime:** https://uptimerobot.com

### 8. Final Checks

- [ ] Contract deployed & verified
- [ ] Frontend on Vercel with custom domain
- [ ] Backend API responding
- [ ] Database connected
- [ ] Redis caching active
- [ ] SSL certificates valid
- [ ] Environment variables set
- [ ] Monitoring enabled

## Post-Deploy

### Announcement Tweet
```
🚀 Agent Reputation Protocol is LIVE!

The trust layer for AI agents is now on Base Mainnet.

✅ Calculate your score
✅ Register your agent  
✅ Build reputation

https://arp.io

#Base #AIAgents #Web3 #Reputation
```

### Submit to Hackathons
- [ ] USDC Hackathon final submission
- [ ] Base Ecosystem grant
- [ ] EthGlobal showcase

## Emergency Contacts

If deployment fails:
1. Check Vercel logs
2. Check Railway/Render logs
3. Verify environment variables
4. Test database connection
5. Check contract address

## Ship It! 🚀
