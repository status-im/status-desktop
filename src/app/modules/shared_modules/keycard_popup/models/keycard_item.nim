import NimQml, strformat
import key_pair_item

export key_pair_item

QtObject:
  type KeycardItem* = ref object of KeyPairItem
    keycardUid: string

  proc delete*(self: KeycardItem) =
      self.KeyPairItem.delete

  proc initKeycardItem*(
      keycardUid = "",
      keyUid = "",
      pubKey = "",
      locked = false,
      name = "",
      image = "",
      icon = "",
      pairType = KeyPairType.Unknown,
      derivedFrom = ""
      ): KeycardItem =
    new(result, delete)
    result.KeyPairItem.setup(keyUid, pubKey, locked, name, image, icon, pairType, derivedFrom)
    result.keycardUid = keycardUid

  proc `$`*(self: KeycardItem): string =
    result = fmt"""KeycardItem[
      keycardUid: {self.keycardUid},
      pubKey: {self.getPubKey()},
      keyUid: {self.getKeyUid()},
      locked: {self.getLocked()},
      name: {self.getName()},
      image: {self.getImage()},
      icon: {self.getIcon()},
      pairType: {$self.getPairType()},
      derivedFrom: {self.getDerivedFrom()},
      accounts: {self.getAccountsModel()}
      ]"""

  proc keycardUidChanged*(self: KeycardItem) {.signal.}
  proc getKeycardUid*(self: KeycardItem): string {.slot.} =
    return self.keycardUid
  proc setKeycardUid*(self: KeycardItem, value: string) {.slot.} =
    self.keycardUid = value
    self.keycardUidChanged()
  QtProperty[string] keycardUid:
    read = getKeycardUid
    write = setKeycardUid
    notify = keycardUidChanged