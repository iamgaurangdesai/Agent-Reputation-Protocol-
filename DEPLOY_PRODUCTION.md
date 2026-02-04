# 🚀 Production Deployment Guide

## Overview
Deploy ARP full-stack to production with:
- **Backend**: Railway (free tier)
- **Frontend**: Vercel (free tier)
- **Database**: Railway PostgreSQL (free tier)

---

## Step 1: Deploy Backend to Railway

### 1.1 Sign up at https://railway.app
- Login with GitHub
- No credit card required for free tier

### 1.2 Create Project
```bash
# Install Railway CLI (optional, but helpful)
npm install -g @railway/cli

# Or use web dashboard:
# 1. Click "New Project"
# 2. Select "Deploy from GitHub repo"
# 3. Choose your ARP repo
# 4. Set root directory: fullstack/backend
```

### 1.3 Add PostgreSQL Database
In Railway dashboard:
1. Click "New" → "Database" → "Add PostgreSQL"
2. Wait for provisioning (takes ~1 minute)
3. Click on the database → "Connect"
4. Copy the `DATABASE_URL`

### 1.4 Environment Variables
In Railway dashboard → your service → Variables:

```
PRIVY_APP_ID=cml80zr3300mwjy0bpa3t4hbm
PRIVY_APP_SECRET=privy_app_secret_5yVjYiLTt2UpXL9iGEcD99gz2Rux4ogoD9kjwemEsYQbZ1iz1LK39bMUuHke76j4nBi4tdxT7PXcaUkYYNWCTDFf
DATABASE_URL=${{Postgres.DATABASE_URL}}  # Auto-filled by Railway
CONTRACT_ADDRESS_BASE_SEPOLIA=0xC1ffe755E8641b76f37e6bb8F97BB5321Fdf0C39
CONTRACT_ADDRESS_BASE_MAINNET=your_mainnet_address
PORT=3001
NODE_ENV=production
JWT_SECRET=generate_a_random_32_char_string_here
```

### 1.5 Deploy
```bash
# Using CLI (if installed)
cd fullstack/backend
railway login
railway link
railway up

# Or just push to GitHub - Railway auto-deploys
```

### 1.6 Get Backend URL
After deployment:
- Railway dashboard → your service → Settings
- Copy the domain: `https://arp-backend-production.up.railway.app`

---

## Step 2: Deploy Frontend to Vercel

### 2.1 Sign up at https://vercel.com
- Login with GitHub
- Import your ARP repository

### 2.2 Configure Project
```bash
# Using Vercel CLI
npm install -g vercel

cd fullstack/frontend
vercel

# Or use web dashboard:
# 1. Click "Add New Project"
# 2. Import from GitHub
# 3. Framework: Next.js
# 4. Root: fullstack/frontend
```

### 2.3 Environment Variables
In Vercel dashboard → Project → Settings → Environment Variables:

```
NEXT_PUBLIC_PRIVY_APP_ID=cml80zr3300mwjy0bpa3t4hbm
NEXT_PUBLIC_API_URL=https://your-railway-backend-url.railway.app
NEXT_PUBLIC_CONTRACT_ADDRESS_BASE_SEPOLIA=0xC1ffe755E8641b76f37e6bb8F97BB5321Fdf0C39
```

### 2.4 Deploy
```bash
vercel --prod

# Or push to GitHub - Vercel auto-deploys
```

---

## Step 3: Update Privy Dashboard

Go to https://dashboard.privy.io → Your App → Settings:

1. **Allowed Origins**:
   ```
   http://localhost:3000
   https://your-vercel-domain.vercel.app
   https://arp.io  (if you have custom domain)
   ```

2. **Allowed Redirect URLs**:
   ```
   http://localhost:3000
   https://your-vercel-domain.vercel.app
   ```

---

## Step 4: Test Production

### 4.1 Health Check
```bash
curl https://your-railway-backend.railway.app/health
# Should return: {"status":"ok"}
```

### 4.2 Full Test
1. Open Vercel frontend URL
2. Click "Connect Wallet"
3. Login with email/social
4. Create agent wallet
5. Register agent on Base Sepolia

---

## Costs (Free Tier)

| Service | Free Tier | Paid (if needed) |
|---------|-----------|------------------|
| Railway | $5/month credit | $5/month per service |
| Vercel | Hobby (unlimited) | Pro $20/month |
| PostgreSQL | 500 MB, 1 GB RAM | $5/month |
| Privy | 1,000 MAU | $0.01 per MAU |

**Estimated cost for hackathon + early users: $0-5/month**

---

## Custom Domain (Optional)

### Frontend (Vercel)
1. Vercel dashboard → Domains
2. Add `arp.io` or subdomain
3. Update DNS records

### Backend (Railway)
1. Railway dashboard → your service → Settings
2. Add custom domain
3. Update DNS records

---

## Troubleshooting

### Backend won't start
```bash
# Check logs in Railway dashboard
railway logs

# Common issues:
# - Missing env variables
# - DATABASE_URL not set
# - Build failed (check package.json)
```

### Frontend can't connect to backend
```bash
# Check CORS is enabled in backend/src/index.ts
# Verify NEXT_PUBLIC_API_URL is correct
# Check browser console for errors
```

### Privy login fails
```bash
# Verify allowed origins in Privy dashboard
# Check App ID is correct
# Ensure redirect URLs match
```

---

## Quick Commands

```bash
# Deploy backend only
cd fullstack/backend && railway up

# Deploy frontend only
cd fullstack/frontend && vercel --prod

# View logs
railway logs
vercel logs

# Open in browser
vercel open
```

---

## URLs After Deployment

| Service | URL |
|---------|-----|
| Frontend | `https://arp-xyz123.vercel.app` |
| Backend | `https://arp-backend.railway.app` |
| API Docs | `https://arp-backend.railway.app/api-docs` |

---

**Ready to deploy? Follow the steps above!** 🚀

**Need help? Send me the error message and I'll fix it!** 🔧
