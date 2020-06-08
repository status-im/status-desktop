import eventemitter

type CurrencyArgs* = ref object of Args
    currency*: string

type Asset* = ref object
    name*, symbol*, value*, fiatValue*, image*: string
    hasIcon*: bool

type Account* = ref object
    name*, address*, iconColor*, balance*: string
    realFiatBalance*: float
    assetList*: seq[Asset]

type AccountArgs* = ref object of Args
    account*: Account
