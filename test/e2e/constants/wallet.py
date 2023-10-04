from enum import Enum


class DerivationPath(Enum):
    CUSTOM = 'Custom'
    ETHEREUM = 'Ethereum'
    ETHEREUM_ROPSTEN = 'Ethereum Testnet (Ropsten)'
    ETHEREUM_LEDGER = 'Ethereum (Ledger)'
    ETHEREUM_LEDGER_LIVE = 'Ethereum (Ledger Live/KeepKey)'


class WalletNetworkSettings(Enum):
    TESTNET_SUBTITLE = 'Switch entire Status app to testnet only mode'
    TESTNET_ENABLED_TOAST_MESSAGE = 'Testnet mode turned on'
    TESTNET_DISABLED_TOAST_MESSAGE = 'Testnet mode turned off'


class WalletNetworkNaming(Enum):
    LAYER1_ETHEREUM = 'Mainnet'
    LAYER2_OPTIMISIM = 'Optimism'
    LAYER2_ARBITRUM = 'Arbitrum'
    ETHEREUM_MAINNET_NETWORK_ID = 1
    ETHEREUM_GOERLI_NETWORK_ID = 5
    OPTIMISM_MAINNET_NETWORK_ID = 10
    OPTIMISM_GOERLI_NETWORK_ID = 420
    ARBITRUM_MAINNET_NETWORK_ID = 42161
    ARBITRUM_GOERLI_NETWORK_ID = 421613


class WalletNetworkDefaultValues(Enum):
    ETHEREUM_LIVE_MAIN = 'https://eth-archival.gateway.pokt.network/v1/lb/********'
    ETHEREUM_LIVE_FAILOVER = 'https://mainnet.infura.io/v3/********************************'
