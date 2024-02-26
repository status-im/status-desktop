from enum import Enum


class DerivationPath(Enum):
    CUSTOM = 'Custom'
    ETHEREUM = 'Ethereum'
    ETHEREUM_ROPSTEN = 'Ethereum Testnet (Ropsten)'
    ETHEREUM_LEDGER = 'Ethereum (Ledger)'
    ETHEREUM_LEDGER_LIVE = 'Ethereum (Ledger Live/KeepKey)'
    STATUS_ACCOUNT_DERIVATION_PATH = "m / 44' / 60' / 0' / 0 / 0"
    GENERATED_ACCOUNT_DERIVATION_PATH_1 = "m / 44' / 60' / 0' / 0 / 1"


class WalletNetworkSettings(Enum):
    EDIT_NETWORK_LIVE_TAB = 'Live Network'
    EDIT_NETWORK_TEST_TAB = 'Test Network'
    TESTNET_SUBTITLE = 'Switch entire Status app to testnet only mode'
    TESTNET_ENABLED_TOAST_MESSAGE = 'Testnet mode turned on'
    TESTNET_DISABLED_TOAST_MESSAGE = 'Testnet mode turned off'
    ACKNOWLEDGMENT_CHECKBOX_TEXT = ('I understand that changing network settings can cause unforeseen issues, errors, '
                                    'security risks and potentially even loss of funds.')
    REVERT_TO_DEFAULT_LIVE_MAINNET_TOAST_MESSAGE = 'Live network settings for Mainnet reverted to default'
    REVERT_TO_DEFAULT_TEST_MAINNET_TOAST_MESSAGE = 'Test network settings for Mainnet reverted to default'
    STATUS_ACCOUNT_DEFAULT_NAME = 'Status account'
    STATUS_ACCOUNT_DEFAULT_COLOR = '#2a4af5'


class WalletAccountSettings(Enum):
    STATUS_ACCOUNT_ORIGIN = 'Derived from your default Status keypair'
    WATCHED_ADDRESS_ORIGIN = 'Watched address'
    STORED_ON_DEVICE = 'On device'
    WATCHED_ADDRESSES_KEYPAIR_LABEL = 'Watched addresses'


class WalletNetworkNaming(Enum):
    LAYER1_ETHEREUM = 'Mainnet'
    LAYER2_OPTIMISIM = 'Optimism'
    LAYER2_ARBITRUM = 'Arbitrum'
    ETHEREUM_MAINNET_NETWORK_ID = 1
    ETHEREUM_SEPOLIA_NETWORK_ID = 11155111
    OPTIMISM_MAINNET_NETWORK_ID = 10
    OPTIMISM_SEPOLIA_NETWORK_ID = 11155420
    ARBITRUM_MAINNET_NETWORK_ID = 42161
    ARBITRUM_SEPOLIA_NETWORK_ID = 421614


class WalletNetworkDefaultValues(Enum):
    ETHEREUM_LIVE_MAIN = 'https://eth-archival.rpc.grove.city'
    ETHEREUM_TEST_MAIN = 'https://sepolia-archival.rpc.grove.city'
    ETHEREUM_LIVE_FAILOVER = 'https://mainnet.infura.io'
    ETHEREUM_TEST_FAILOVER = 'https://sepolia.infura.io'


class WalletEditNetworkErrorMessages(Enum):
    PINGUNSUCCESSFUL = 'RPC appears to be either offline or this is not a valid JSON RPC endpoint URL'
    PINGVERIFIED = 'RPC successfully reached'


class WalletOrigin(Enum):
    WATCHED_ADDRESS_ORIGIN = 'New watched address'


class WalletTransactions(Enum):
    TRANSACTION_PENDING_TOAST_MESSAGE = 'Transaction pending'


class WalletScreensHeaders(Enum):
    WALLET_ADD_ACCOUNT_POPUP_TITLE = 'Add a new account'
