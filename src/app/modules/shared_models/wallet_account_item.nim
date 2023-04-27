import strformat

type
  WalletAccountItem* = ref object of RootObj
    name: string
    address: string
    color: string
    emoji: string
    walletType: string
    path: string
    keyUid: string

proc setup*(self: WalletAccountItem,
  name: string = "",
  address: string = "",
  color: string = "",
  emoji: string = "",
  walletType: string = "",
  path: string = "",
  keyUid: string = ""
  ) =
    self.name = name
    self.address = address
    self.color = color
    self.emoji = emoji
    self.walletType = walletType
    self.path = path
    self.keyUid = keyUid

proc initWalletAccountItem*(
  name: string = "",
  address: string = "",
  color: string = "",
  emoji: string = "",
  walletType: string = "",
  path: string = "",
  keyUid: string = ""
  ): WalletAccountItem =
  result = WalletAccountItem()
  result.setup(name,
    address,
    color,
    emoji,
    walletType,
    path,
    keyUid)
  

proc `$`*(self: WalletAccountItem): string =
  result = fmt"""WalletAccountItem(
    name: {self.name},
    address: {self.address},
    color: {self.color},
    emoji: {self.emoji},
    walletType: {self.walletType},
    path: {self.path},
    keyUid: {self.keyUid},
    ]"""

proc name*(self: WalletAccountItem): string {.inline.} =
  return self.name

proc `name=`*(self: WalletAccountItem, value: string) {.inline.} =
  self.name = value

proc address*(self: WalletAccountItem): string {.inline.} =
  return self.address

proc emoji*(self: WalletAccountItem): string {.inline.} =
  return self.emoji

proc `emoji=`*(self: WalletAccountItem, value: string) {.inline.} =
  self.emoji = value

proc color*(self: WalletAccountItem): string {.inline.} =
  return self.color

proc `color=`*(self: WalletAccountItem, value: string) {.inline.} =
  self.color = value

proc walletType*(self: WalletAccountItem): string {.inline.} =
  return self.walletType

proc path*(self: WalletAccountItem): string {.inline.} =
  return self.path

proc keyUid*(self: WalletAccountItem): string {.inline.} =
  return self.keyUid