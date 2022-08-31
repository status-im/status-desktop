import strformat, marshal

type
  KeyPairType* {.pure.} = enum
    Unknown = -1
    Profile
    SeedImport
    PrivateKeyImport

type
  WalletAccountDetails = tuple
    name: string
    path: string
    address: string
    emoji: string
    color: string
    icon: string
    balance: float64

type
  KeyPairItem* = ref object of RootObj
    pubKey: string
    name: string
    image: string
    icon: string
    derivedFrom: string
    pairType: KeyPairType
    accounts: seq[WalletAccountDetails]
    
proc initKeyPairItem*(
    pubKey: string,
    name: string,
    image: string,
    icon: string,
    pairType: KeyPairType,
    derivedFrom: string
    ): KeyPairItem =
  result = KeyPairItem()
  result.pubKey = pubKey
  result.name = name
  result.image = image
  result.icon = icon
  result.pairType = pairType
  result.derivedFrom = derivedFrom

proc `$`*(self: KeyPairItem): string =
  result = fmt"""KeyPairItem[
    pubKey: {self.pubkey},
    name: {self.name},
    image: {self.image},
    icon: {self.icon},
    pairType: {$self.pairType},
    derivedFrom: {self.derivedFrom},
    accounts: {$self.accounts}
    ]"""

proc pubKey*(self: KeyPairItem): string {.inline.} =
  self.pubKey

proc name*(self: KeyPairItem): string {.inline.} =
  self.name

proc image*(self: KeyPairItem): string {.inline.} =
  self.image

proc icon*(self: KeyPairItem): string {.inline.} =
  self.icon

proc pairType*(self: KeyPairItem): KeyPairType {.inline.} =
  self.pairType

proc derivedFrom*(self: KeyPairItem): string {.inline.} =
  self.derivedFrom

proc addAccount*(self: KeyPairItem, name, path, address, emoji, color, icon: string, balance: float64) {.inline.} =
  self.accounts.add((name: name, path: path, address: address, emoji: emoji, color: color, icon: icon, balance: balance))

proc accounts*(self: KeyPairItem): string {.inline.} =
  return $$self.accounts

proc accountsAsArr*(self: KeyPairItem): seq[WalletAccountDetails] {.inline.} =
  return self.accounts