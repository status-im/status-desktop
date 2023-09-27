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

