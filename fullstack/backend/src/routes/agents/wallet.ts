import { NextApiRequest, NextApiResponse } from 'next';
import { PrivyClient } from '@privy-io/server-auth';

// Initialize Privy Server Client
// NEVER expose these to frontend!
const privy = new PrivyClient(
  process.env.PRIVY_APP_ID!,
  process.env.PRIVY_APP_SECRET!
);

// Policy ID for ARP agents (create in Privy dashboard)
const AGENT_POLICY_ID = process.env.PRIVY_AGENT_POLICY_ID;

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { agentName, userWallet } = req.body;

    // Validate request
    if (!agentName || !userWallet) {
      return res.status(400).json({ 
        error: 'Missing required fields: agentName, userWallet' 
      });
    }

    // Create embedded wallet for the AI agent
    const wallet = await privy.walletApi.create({
      type: 'ethereum',
      policyIds: AGENT_POLICY_ID ? [AGENT_POLICY_ID] : undefined,
      description: `ARP Agent: ${agentName}`,
      // Link to the user who created this agent
      customMetadata: {
        agentName,
        createdBy: userWallet,
        createdAt: new Date().toISOString(),
        type: 'arp-agent'
      }
    });

    // Store in database (you'll need to implement this)
    // await db.agents.create({
    //   name: agentName,
    //   walletAddress: wallet.address,
    //   privyWalletId: wallet.id,
    //   owner: userWallet
    // });

    return res.status(200).json({
      success: true,
      wallet: {
        id: wallet.id,
        address: wallet.address,
        chainType: wallet.chainType,
        createdAt: wallet.createdAt
      },
      message: 'Agent wallet created successfully'
    });

  } catch (error) {
    console.error('Failed to create agent wallet:', error);
    return res.status(500).json({ 
      error: 'Failed to create agent wallet',
      details: error.message 
    });
  }
}

// Execute transaction on behalf of agent (autonomous)
export async function executeAgentTransaction(
  agentWalletId: string,
  transaction: {
    to: string;
    data: string;
    value?: string;
  }
) {
  try {
    // This will only succeed if within policy constraints
    const tx = await privy.walletApi.ethereum.sendTransaction(
      agentWalletId,
      {
        to: transaction.to,
        data: transaction.data,
        value: transaction.value || '0x0'
      }
    );

    return {
      success: true,
      hash: tx.hash,
      status: tx.status
    };
  } catch (error) {
    console.error('Agent transaction failed:', error);
    
    // Check if it was a policy violation
    if (error.message.includes('policy')) {
      return {
        success: false,
        error: 'Policy violation',
        details: 'Transaction exceeded policy limits'
      };
    }
    
    throw error;
  }
}

// Get agent wallet balance
export async function getAgentWalletBalance(agentWalletId: string) {
  const wallet = await privy.walletApi.get(agentWalletId);
  
  return {
    address: wallet.address,
    balance: wallet.balance,
    chainId: wallet.chainId
  };
}
