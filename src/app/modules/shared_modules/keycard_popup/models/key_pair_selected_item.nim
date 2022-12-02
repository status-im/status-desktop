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
  proc keyPairSelectedItemLockedChanged*(self: KeyPairSelectedItem) {.signal.}
  proc keyPairSelectedItemIconChanged*(self: KeyPairSelectedItem) {.signal.}
  proc keyPairSelectedItemNameChanged*(self: KeyPairSelectedItem) {.signal.}

  proc setItem*(self: KeyPairSelectedItem, item: KeyPairItem) =
    self.item = item
    self.keyPairSelectedItemChanged()
    self.keyPairSelectedItemLockedChanged()
    self.keyPairSelectedItemIconChanged()

  proc updateLockedState*(self: KeyPairSelectedItem, locked: bool) =
    if self.item.isNil:
      return
    self.item.setLocked(locked)
    if locked:
      self.item.setIcon("lock")
    else:
      self.item.setIcon("keycard")
    self.keyPairSelectedItemLockedChanged()
    self.keyPairSelectedItemIconChanged()

  proc getKeyUid*(self: KeyPairSelectedItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.keyUid()
  QtProperty[string] keyUid:
    read = getKeyUid
    notify = keyPairSelectedItemChanged

  proc getPubKey*(self: KeyPairSelectedItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.pubKey()
  QtProperty[string] pubKey:
    read = getPubKey
    notify = keyPairSelectedItemChanged

  proc getLocked*(self: KeyPairSelectedItem): bool {.slot.} =
    if(self.item.isNil):
      return false
    return self.item.locked()
  QtProperty[bool] locked:
    read = getLocked
    notify = keyPairSelectedItemLockedChanged

  proc getName*(self: KeyPairSelectedItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.name()
  QtProperty[string] name:
    read = getName
    notify = keyPairSelectedItemChanged
  proc updateName*(self: KeyPairSelectedItem, name: string) =
    if self.item.isNil:
      return
    self.item.setName(name)
    self.keyPairSelectedItemNameChanged()

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
    notify = keyPairSelectedItemIconChanged

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