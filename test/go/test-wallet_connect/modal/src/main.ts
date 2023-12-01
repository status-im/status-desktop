import { createWeb3Modal, walletConnectProvider, EIP6963Connector } from '@web3modal/wagmi'

import { configureChains, createConfig } from '@wagmi/core'
import { goerli } from 'viem/chains'
import { publicProvider } from '@wagmi/core/providers/public'
import { InjectedConnector } from '@wagmi/core'
import { CoinbaseWalletConnector } from '@wagmi/core/connectors/coinbaseWallet'
import { WalletConnectConnector } from '@wagmi/core/connectors/walletConnect'

const projectId = '0ff537ebcebc5ce0947866d3a90e0ebf'

const { chains, publicClient } = configureChains([goerli], [
  walletConnectProvider({ projectId }),
  publicProvider()
])

const metadata = {
  name: 'Test Web3Modal',
  description: 'Web3Modal Test',
  url: 'https://web3modal.com',
  icons: ['https://avatars.githubusercontent.com/u/37784886']
}

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors: [
    new WalletConnectConnector({ chains, options: { projectId, showQrModal: false, metadata } }),
    new EIP6963Connector({ chains }),
    new InjectedConnector({ chains, options: { shimDisconnect: true } }),
    new CoinbaseWalletConnector({ chains, options: { appName: metadata.name } })
  ],
  publicClient
})

const testWalletIds = [
  'statusDesktopTest',
  'af9a6dfff9e63977bbde28fb23518834f08b696fe8bff6dd6827acad1814c6be' // Status Mobile
]
const modal = createWeb3Modal({ wagmiConfig, projectId, chains,
  customWallets: [
    {
      id: 'statusDesktopTest',
      name: 'Status Desktop Test',
      homepage: 'https://status.app/', // Optional
      image_url: 'https://res.cloudinary.com/dhgck7ebz/image/upload/f_auto,c_limit,w_1080,q_auto/Brand/Logo%20Section/Mark/Mark_01', // Optional
      //mobile_link: 'mobile_link', // Optional - Deeplink or universal
      desktop_link: 'status-app://', // Optional - Deeplink
      //webapp_link: 'webapp_link', // Optional
      //app_store: 'app_store', // Optional
      //play_store: 'play_store' // Optional
    }
  ],
  featuredWalletIds: testWalletIds,
  includeWalletIds: testWalletIds
})
modal.open({ view: 'All wallets' })