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
    keyUid: string
    locked: bool
    name: string
    image: string
    icon: string
    derivedFrom: string
    pairType: KeyPairType
    accounts: seq[WalletAccountDetails]
    
proc initKeyPairItem*(
    pubKey = "",
    keyUid = "",
    locked = false,
    name = "",
    image = "",
    icon = "",
    pairType = KeyPairType.Unknown,
    derivedFrom = ""
    ): KeyPairItem =
  result = KeyPairItem()
  result.pubKey = pubKey
  result.keyUid = keyUid
  result.name = name
  result.image = image
  result.icon = icon
  result.pairType = pairType
  result.derivedFrom = derivedFrom

proc `$`*(self: KeyPairItem): string =
  result = fmt"""KeyPairItem[
    pubKey: {self.pubkey},
    keyUid: {self.keyUid},
    name: {self.name},
    image: {self.image},
    icon: {self.icon},
    pairType: {$self.pairType},
    derivedFrom: {self.derivedFrom},
    accounts: {$self.accounts}
    ]"""

proc pubKey*(self: KeyPairItem): string {.inline.} =
  self.pubKey
proc setPubKey*(self: KeyPairItem, value: string) {.inline.} =
  self.pubKey = value

proc keyUid*(self: KeyPairItem): string {.inline.} =
  self.keyUid
proc setKeyUid*(self: KeyPairItem, value: string) {.inline.} =
  self.keyUid = value

proc locked*(self: KeyPairItem): bool {.inline.} =
  self.locked
proc setLocked*(self: KeyPairItem, value: bool) {.inline.} =
  self.locked = value

proc name*(self: KeyPairItem): string {.inline.} =
  self.name
proc setName*(self: KeyPairItem, value: string) {.inline.} =
  self.name = value

proc image*(self: KeyPairItem): string {.inline.} =
  self.image
proc setImage*(self: KeyPairItem, value: string) {.inline.} =
  self.image = value

proc icon*(self: KeyPairItem): string {.inline.} =
  self.icon
proc setIcon*(self: KeyPairItem, value: string) {.inline.} =
  self.icon = value

proc pairType*(self: KeyPairItem): KeyPairType {.inline.} =
  self.pairType
proc setPairType*(self: KeyPairItem, value: KeyPairType) {.inline.} =
  self.pairType = value

proc derivedFrom*(self: KeyPairItem): string {.inline.} =
  self.derivedFrom

proc addAccount*(self: KeyPairItem, name, path, address, emoji, color, icon: string, balance: float64) {.inline.} =
  self.accounts.add((name: name, path: path, address: address, emoji: emoji, color: color, icon: icon, balance: balance))

proc accounts*(self: KeyPairItem): string {.inline.} =
  return $$self.accounts

proc accountsAsArr*(self: KeyPairItem): seq[WalletAccountDetails] {.inline.} =
  return self.accounts