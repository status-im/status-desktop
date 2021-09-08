import options, json, strformat

from ../../eventemitter import Args
import ../types

type CollectibleList* = ref object
    collectibleType*, collectiblesJSON*, error*: string
    loading*: int

type Collectible* = ref object
    name*, image*, id*, collectibleType*, description*, externalUrl*: string

type CurrencyArgs* = ref object of Args
    currency*: string

type Asset* = ref object
    name*, symbol*, value*, fiatBalanceDisplay*, fiatBalance*,  accountAddress*, address*: string

type WalletAccount* = ref object
    name*, address*, iconColor*, path*, walletType*, publicKey*: string
    balance*: Option[string]
    realFiatBalance*: Option[float]
    assetList*: seq[Asset]
    wallet*, chat*: bool
    collectiblesLists*: seq[CollectibleList]
    transactions*: tuple[hasMore: bool, data: seq[Transaction]]

type AccountArgs* = ref object of Args
    account*: WalletAccount