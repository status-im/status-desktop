import NimQml, strformat

QtObject:
  type KeyPairAccountItem* = ref object of QObject
    name: string
    path: string
    address: string
    pubKey: string
    emoji: string
    color: string
    icon: string
    balance: float

  proc delete*(self: KeyPairAccountItem) =
    self.QObject.delete

  proc newKeyPairAccountItem*(name = "", path = "", address = "", pubKey = "", emoji = "", color = "", icon = "", 
    balance = 0.0): KeyPairAccountItem =
    new(result, delete)
    result.QObject.setup
    result.name = name
    result.path = path
    result.address = address
    result.pubKey = pubKey
    result.emoji = emoji
    result.color = color
    result.icon = icon
    result.balance = balance

  proc `$`*(self: KeyPairAccountItem): string =
    result = fmt"""KeyPairAccountItem[
      name: {self.name},
      path: {self.path},
      address: {self.address},
      pubKey: {self.pubKey},
      emoji: {self.emoji},
      color: {self.color},
      icon: {self.icon},
      icon: {$self.icon},
      balance: {self.balance}
      ]"""

  proc nameChanged*(self: KeyPairAccountItem) {.signal.}
  proc getName*(self: KeyPairAccountItem): string {.slot.} =
    return self.name
  proc setName*(self: KeyPairAccountItem, value: string) {.slot.} =
    self.name = value
    self.nameChanged()
  QtProperty[string] name:
    read = getName
    write = setName
    notify = nameChanged

  proc pathChanged*(self: KeyPairAccountItem) {.signal.}
  proc getPath*(self: KeyPairAccountItem): string {.slot.} =
    return self.path
  proc setPath*(self: KeyPairAccountItem, value: string) {.slot.} =
    self.path = value
    self.pathChanged()
  QtProperty[string] path:
    read = getPath
    write = setPath
    notify = pathChanged

  proc addressChanged*(self: KeyPairAccountItem) {.signal.}
  proc getAddress*(self: KeyPairAccountItem): string {.slot.} =
    return self.address
  proc setAddress*(self: KeyPairAccountItem, value: string) {.slot.} =
    self.address = value
    self.addressChanged()
  QtProperty[string] address:
    read = getAddress
    write = setAddress
    notify = addressChanged

  proc pubKeyChanged*(self: KeyPairAccountItem) {.signal.}
  proc getPubKey*(self: KeyPairAccountItem): string {.slot.} =
    return self.pubKey
  proc setPubKey*(self: KeyPairAccountItem, value: string) {.slot.} =
    self.pubKey = value
    self.pubKeyChanged()
  QtProperty[string] pubKey:
    read = getPubKey
    write = setPubKey
    notify = pubKeyChanged

  proc emojiChanged*(self: KeyPairAccountItem) {.signal.}
  proc getEmoji*(self: KeyPairAccountItem): string {.slot.} =
    return self.emoji
  proc setEmoji*(self: KeyPairAccountItem, value: string) {.slot.} =
    self.emoji = value
    self.emojiChanged()
  QtProperty[string] emoji:
    read = getEmoji
    write = setEmoji
    notify = emojiChanged

  proc colorChanged*(self: KeyPairAccountItem) {.signal.}
  proc getColor*(self: KeyPairAccountItem): string {.slot.} =
    return self.color
  proc setColor*(self: KeyPairAccountItem, value: string) {.slot.} =
    self.color = value
    self.colorChanged()
  QtProperty[string] color:
    read = getColor
    write = setColor
    notify = colorChanged

  proc iconChanged*(self: KeyPairAccountItem) {.signal.}
  proc getIcon*(self: KeyPairAccountItem): string {.slot.} =
    return self.icon
  proc setIcon*(self: KeyPairAccountItem, value: string) {.slot.} =
    self.icon = value
    self.iconChanged()
  QtProperty[string] icon:
    read = getIcon
    write = setIcon
    notify = iconChanged

  proc balanceChanged*(self: KeyPairAccountItem) {.signal.}
  proc getBalance*(self: KeyPairAccountItem): float {.slot.} =
    return self.balance
  proc setBalance*(self: KeyPairAccountItem, value: float) {.slot.} =
    self.balance = value
    self.balanceChanged()
  QtProperty[float] balance:
    read = getBalance
    write = setBalance
    notify = balanceChanged