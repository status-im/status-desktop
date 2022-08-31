import NimQml
import key_pair_item

QtObject:
  type KeyPairSelectedItem* = ref object of QObject
    item: KeyPairItem

  proc delete*(self: KeyPairSelectedItem) =
    self.QObject.delete

  proc newKeyPairSelectedItem*(): KeyPairSelectedItem =
    new(result, delete)
    result.QObject.setup

  proc keyPairSelectedItemChanged*(self: KeyPairSelectedItem) {.signal.}

  proc setItem*(self: KeyPairSelectedItem, item: KeyPairItem) =
    self.item = item
    self.keyPairSelectedItemChanged()

  proc getPubKey*(self: KeyPairSelectedItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.pubKey()
  QtProperty[string] pubKey:
    read = getPubKey
    notify = keyPairSelectedItemChanged

  proc getName*(self: KeyPairSelectedItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.name()
  QtProperty[string] name:
    read = getName
    notify = keyPairSelectedItemChanged

  proc getImage*(self: KeyPairSelectedItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.image()
  QtProperty[string] image:
    read = getImage
    notify = keyPairSelectedItemChanged

  proc getIcon*(self: KeyPairSelectedItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.icon()
  QtProperty[string] icon:
    read = getIcon
    notify = keyPairSelectedItemChanged

  proc getPairType*(self: KeyPairSelectedItem): int {.slot.} =
    if(self.item.isNil):
      return KeyPairType.Profile.int
    return self.item.pairType().int
  QtProperty[int] pairType:
    read = getPairType
    notify = keyPairSelectedItemChanged

  proc getDerivedFrom*(self: KeyPairSelectedItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.derivedFrom()
  QtProperty[string] derivedFrom:
    read = getDerivedFrom
    notify = keyPairSelectedItemChanged

  proc getAccounts*(self: KeyPairSelectedItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.accounts()
  QtProperty[string] accounts:
    read = getAccounts
    notify = keyPairSelectedItemChanged