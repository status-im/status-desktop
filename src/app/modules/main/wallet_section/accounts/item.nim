import strformat
import ../../../shared_models/token_model as token_model
import ../../../shared_models/currency_amount
import ./compact_model as compact_model

type
  Item* = object
    name: string
    address: string
    mixedCaseAddress: string
    path: string
    color: string
    publicKey: string
    walletType: string
    isWallet: bool
    isChat: bool
    currencyBalance: CurrencyAmount
    assets: token_model.Model
    emoji: string
    derivedfrom: string
    relatedAccounts: compact_model.Model
    keyUid: string
    migratedToKeycard: bool
    ens: string

proc initItem*(
  name: string,
  address: string,
  mixedCaseAddress: string,
  path: string,
  color: string,
  publicKey: string,
  walletType: string,
  isWallet: bool,
  isChat: bool,
  currencyBalance: CurrencyAmount,
  assets: token_model.Model,
  emoji: string,
  derivedfrom: string,
  relatedAccounts: compact_model.Model,
  keyUid: string,
  migratedToKeycard: bool,
  ens: string
): Item =
  result.name = name
  result.address = address
  result.mixedCaseAddress = mixedCaseAddress
  result.path = path
  result.color = color
  result.publicKey = publicKey
  result.walletType = walletType
  result.isWallet = isWallet
  result.isChat = isChat
  result.currencyBalance = currencyBalance
  result.assets = assets
  result.emoji = emoji
  result.derivedfrom = derivedfrom
  result.relatedAccounts = relatedAccounts
  result.keyUid = keyUid
  result.migratedToKeycard = migratedToKeycard
  result.ens = ens

proc `$`*(self: Item): string =
  result = fmt"""WalletAccountItem(
    name: {self.name},
    address: {self.address},
    mixedCaseAddress: {self.mixedCaseAddress},
    path: {self.path},
    color: {self.color},
    publicKey: {self.publicKey},
    walletType: {self.walletType},
    isWallet: {self.isWallet},
    isChat: {self.isChat},
    currencyBalance: {self.currencyBalance},
    assets.len: {self.assets.getCount()},
    emoji: {self.emoji},
    derivedfrom: {self.derivedfrom},
    relatedAccounts: {self.relatedAccounts}
    keyUid: {self.keyUid},
    migratedToKeycard: {self.migratedToKeycard},
    ens: {self.ens}
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getAddress*(self: Item): string =
  return self.address

proc getMixedCaseAddress*(self: Item): string =
  return self.mixedCaseAddress

proc getPath*(self: Item): string =
  return self.path

proc getEmoji*(self: Item): string =
  return self.emoji

proc getColor*(self: Item): string =
  return self.color

proc getPublicKey*(self: Item): string =
  return self.publicKey

proc getWalletType*(self: Item): string =
  return self.walletType

proc getIsWallet*(self: Item): bool =
  return self.isWallet

proc getIsChat*(self: Item): bool =
  return self.isChat

proc getCurrencyBalance*(self: Item): CurrencyAmount =
  return self.currencyBalance

proc getAssets*(self: Item): token_model.Model =
  return self.assets

proc getDerivedFrom*(self: Item): string =
  return self.derivedfrom

proc getRelatedAccounts*(self: Item): compact_model.Model =
  return self.relatedAccounts

proc getKeyUid*(self: Item): string =
  return self.keyUid

proc getMigratedToKeycard*(self: Item): bool =
  return self.migratedToKeycard

proc getEns*(self: Item): string =
  return self.ens
