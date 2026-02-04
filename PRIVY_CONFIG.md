# Privy Configuration - ARP

## App ID
```
cml80zr3300mwjy0bpa3t4hbm
```

## Environment Variables

### Frontend (.env.local)
```
NEXT_PUBLIC_PRIVY_APP_ID=cml80zr3300mwjy0bpa3t4hbm
```

### Backend (.env)
```
PRIVY_APP_ID=cml80zr3300mwjy0bpa3t4hbm
PRIVY_APP_SECRET=your_app_secret_here
PRIVY_AGENT_POLICY_ID=your_policy_id_here
```

## Next Steps

1. **Get App Secret** from https://dashboard.privy.io
   - Go to Settings → API Keys
   - Generate App Secret
   - Add to backend .env

2. **Create Agent Policy** in Privy Dashboard
   - Go to Policies
   - Create new policy for ARP agents
   - Set limits (max transaction, daily spend)
   - Copy Policy ID to .env

3. **Deploy Full Stack**
   - Deploy Next.js frontend
   - Deploy Express backend
   - Test agent wallet creation

## Features Enabled

✅ Email login
✅ Social login (Google, Twitter, Discord)
✅ Wallet connection (MetaMask, etc.)
✅ Embedded wallets
✅ Agentic wallets (AI agents with autonomous control)
✅ Policy controls

## Demo URLs

- **Current Demo**: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/demo.html
- **Full Stack**: Deploy with `npm run dev` in fullstack/ folder

## Testing

1. Open demo.html
2. Click "Connect Wallet"
3. Approve MetaMask connection
4. Register your agent
5. View your profile

## Migration to Full Privy

For production with full Privy features (email/social login):
```bash
cd fullstack/frontend
npm install
# Add NEXT_PUBLIC_PRIVY_APP_ID to .env.local
npm run dev
```
