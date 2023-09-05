from enum import Enum


class DerivationPath(Enum):
    CUSTOM = 'Custom'
    ETHEREUM = 'Ethereum'
    ETHEREUM_ROPSTEN = 'Ethereum Testnet (Ropsten)'
    ETHEREUM_LEDGER = 'Ethereum (Ledger)'
    ETHEREUM_LEDGER_LIVE = 'Ethereum (Ledger Live/KeepKey)'
