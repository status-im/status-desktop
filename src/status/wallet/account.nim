from eventemitter import Args
import ../libstatus/types

type Collectible* = ref object
    name*, image*, id*: string

type CurrencyArgs* = ref object of Args
    currency*: string

type Asset* = ref object
    name*, symbol*, value*, fiatValue*, accountAddress*, address*: string

type WalletAccount* = ref object
    name*, address*, iconColor*, balance*, path*, walletType*, publicKey*: string
    realFiatBalance*: float
    assetList*: seq[Asset]
    wallet*, chat*: bool
    collectibles*: seq[Collectible]
    transactions*: seq[Transaction]

type AccountArgs* = ref object of Args
    account*: WalletAccount
