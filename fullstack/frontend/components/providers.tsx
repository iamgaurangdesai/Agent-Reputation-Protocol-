'use client'

import { WagmiConfig, createConfig, configureChains } from 'wagmi'
import { base, baseGoerli } from 'wagmi/chains'
import { publicProvider } from 'wagmi/providers/public'
import { RainbowKitProvider, getDefaultWallets } from '@rainbow-me/rainbowkit'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import '@rainbow-me/rainbowkit/styles.css'

const { chains, publicClient } = configureChains(
  [base, baseGoerli],
  [publicProvider()]
)

const { connectors } = getDefaultWallets({
  appName: 'ARP - Agent Reputation Protocol',
  projectId: 'YOUR_WALLET_CONNECT_PROJECT_ID',
  chains,
})

const config = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
})

const queryClient = new QueryClient()

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <WagmiConfig config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider chains={chains}>
          {children}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiConfig>
  )
}