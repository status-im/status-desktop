from collections import namedtuple
from enum import Enum

DEFAULT_ACCOUNT_NAME = 'Account 1'

account_list_item = namedtuple('AccountListItem', ['name', 'color', 'emoji'])


class DerivationPath(Enum):
    CUSTOM = 'Custom'
    ETHEREUM = 'Ethereum'
    ETHEREUM_ROPSTEN = 'Ethereum Testnet (Ropsten)'
    ETHEREUM_LEDGER = 'Ethereum (Ledger)'
    ETHEREUM_LEDGER_LIVE = 'Ethereum (Ledger Live/KeepKey)'
