import strformat
import ../account_tokens/model as account_tokens

type 
  Item* = object
    name: string
    address: string
    path: string
    color: string
    publicKey: string
    walletType: string
    isWallet: bool
    isChat: bool
    currencyBalance: float64
    assets: account_tokens.Model

proc initItem*(
  name: string,
  address: string,
  path: string,
  color: string,
  publicKey: string,
  walletType: string,
  isWallet: bool,
  isChat: bool,
  currencyBalance: float64,
  assets: account_tokens.Model
): Item =
  result.name = name
  result.address = address
  result.path = path
  result.color = color
  result.publicKey = publicKey
  result.walletType = walletType
  result.isWallet = isWallet
  result.isChat = isChat
  result.currencyBalance = currencyBalance
  result.assets = assets

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name}, 
    name: {self.name},
    address: {self.address},
    path: {self.path},
    color: {self.color},
    publicKey: {self.publicKey},
    walletType: {self.walletType},
    isWallet: {self.isWallet},
    isChat: {self.isChat},
    currencyBalance: {self.currencyBalance},
    assets.len: {self.assets.getCount()},
    ]"""

proc getName*(self: Item): string = 
  return self.name

proc getAddress*(self: Item): string = 
  return self.address

proc getPath*(self: Item): string = 
  return self.path

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

proc getCurrencyBalance*(self: Item): float64 = 
  return self.currencyBalance

proc getAssets*(self: Item): account_tokens.Model = 
  return self.assets
