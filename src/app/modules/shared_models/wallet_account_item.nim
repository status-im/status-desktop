import NimQml, strformat

QtObject:
  type WalletAccountItem* = ref object of QObject
    name: string
    address: string
    colorId: string
    emoji: string
    walletType: string
    path: string
    keyUid: string
    keycardAccount: bool

  proc setup*(self: WalletAccountItem,
    name: string = "",
    address: string = "",
    colorId: string = "",
    emoji: string = "",
    walletType: string = "",
    path: string = "",
    keyUid: string = "",
    keycardAccount: bool = false
    ) =
      self.QObject.setup
      self.name = name
      self.address = address
      self.colorId = colorId
      self.emoji = emoji
      self.walletType = walletType
      self.path = path
      self.keyUid = keyUid
      self.keycardAccount = keycardAccount

  proc delete*(self: WalletAccountItem) =
      self.QObject.delete

  proc `$`*(self: WalletAccountItem): string =
    result = fmt"""WalletAccountItem(
      name: {self.name},
      address: {self.address},
      colorId: {self.colorId},
      emoji: {self.emoji},
      walletType: {self.walletType},
      path: {self.path},
      keyUid: {self.keyUid},
      keycardAccount: {self.keycardAccount},
      ]"""

  proc nameChanged*(self: WalletAccountItem) {.signal.}
  proc name*(self: WalletAccountItem): string {.slot.} =
    return self.name
  proc `name=`*(self: WalletAccountItem, value: string) {.inline.} =
    self.name = value
    self.nameChanged()
  QtProperty[string] name:
    read = name
    notify = nameChanged

  proc addressChanged*(self: WalletAccountItem) {.signal.}
  proc address*(self: WalletAccountItem): string {.slot.} =
    return self.address
#  proc setAddress*(self: WalletAccountItem, value: string) {.slot.} =
#    self.address = value
#    self.addressChanged()
  QtProperty[string] address:
    read = address
    notify = addressChanged

  proc colorIdChanged*(self: WalletAccountItem) {.signal.}
  proc colorId*(self: WalletAccountItem): string {.slot.} =
    return self.colorId
  proc `colorId=`*(self: WalletAccountItem, value: string) {.inline.} =
    self.colorId = value
    self.colorIdChanged()
  QtProperty[string] colorId:
    read = colorId
    notify = colorIdChanged

  proc emojiChanged*(self: WalletAccountItem) {.signal.}
  proc emoji*(self: WalletAccountItem): string {.slot.} =
    return self.emoji
  proc `emoji=`*(self: WalletAccountItem, value: string) {.inline.} =
    self.emoji = value
    self.emojiChanged()
  QtProperty[string] emoji:
    read = emoji
    notify = emojiChanged

  proc walletTypeChanged*(self: WalletAccountItem) {.signal.}
  proc walletType*(self: WalletAccountItem): string {.slot.} =
    return self.walletType
  QtProperty[string] walletType:
    read = walletType
    notify = walletTypeChanged

  proc pathChanged*(self: WalletAccountItem) {.signal.}
  proc path*(self: WalletAccountItem): string {.slot.} =
    return self.path
  QtProperty[string] path:
    read = path
    notify = pathChanged

  proc keyUidChanged*(self: WalletAccountItem) {.signal.}
  proc keyUid*(self: WalletAccountItem): string {.slot.} =
    return self.keyUid
  QtProperty[string] keyUid:
    read = keyUid
    notify = keyUidChanged

  proc keycardAccountChanged*(self: WalletAccountItem) {.signal.}
  proc keycardAccount*(self: WalletAccountItem): bool {.slot.} =
    return self.keycardAccount
  QtProperty[bool] keycardAccount:
    read = keycardAccount
    notify = keycardAccountChanged


