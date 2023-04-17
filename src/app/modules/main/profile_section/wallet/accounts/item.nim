import strformat
import ./related_accounts_model as related_accounts_model

type
  Item* = object
    name*: string
    address: string
    color*: string
    emoji*: string
    walletType: string
    path: string
    relatedAccounts: related_accounts_model.Model
    keyUid: string

proc initItem*(
  name: string = "",
  address: string = "",
  path: string = "",
  color: string = "",
  walletType: string = "",
  emoji: string = "",
  relatedAccounts: related_accounts_model.Model = nil,
  keyUid: string = "",
): Item =
  result.name = name
  result.address = address
  result.path = path
  result.color = color
  result.walletType = walletType
  result.emoji = emoji
  result.relatedAccounts = relatedAccounts
  result.keyUid = keyUid

proc `$`*(self: Item): string =
  result = fmt"""WalletAccountItem(
    name: {self.name},
    address: {self.address},
    path: {self.path},
    color: {self.color},
    walletType: {self.walletType},
    emoji: {self.emoji},
    relatedAccounts: {self.relatedAccounts}
    keyUid: {self.keyUid},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getAddress*(self: Item): string =
  return self.address

proc getPath*(self: Item): string =
  return self.path

proc getEmoji*(self: Item): string =
  return self.emoji

proc getColor*(self: Item): string =
  return self.color

proc getWalletType*(self: Item): string =
  return self.walletType

proc getRelatedAccounts*(self: Item): related_accounts_model.Model =
  return self.relatedAccounts

proc getKeyUid*(self: Item): string =
  return self.keyUid