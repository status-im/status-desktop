import strformat
import key_pair_item

export key_pair_item

type
  KeycardItem* = ref object of KeyPairItem
    keycardUid: string

proc initKeycardItem*(
    keycardUid = "",
    pubKey = "",
    keyUid = "",
    locked = false,
    name = "",
    image = "",
    icon = "",
    pairType = KeyPairType.Unknown,
    derivedFrom = ""
    ): KeycardItem =
  result = KeycardItem()
  result.KeyPairItem.setup(pubKey, keyUid, locked, name, image, icon, pairType, derivedFrom)
  result.keycardUid = keycardUid

proc `$`*(self: KeycardItem): string =
  result = fmt"""KeycardItem[
    keycardUid: {self.keycardUid},
    pubKey: {self.pubkey},
    keyUid: {self.keyUid},
    locked: {self.locked},
    name: {self.name},
    image: {self.image},
    icon: {self.icon},
    pairType: {$self.pairType},
    derivedFrom: {self.derivedFrom},
    accounts: {self.accounts}
    ]"""

proc keycardUid*(self: KeycardItem): string {.inline.} =
  self.keycardUid
proc setKeycardUid*(self: KeycardItem, value: string) {.inline.} =
  self.keycardUid = value