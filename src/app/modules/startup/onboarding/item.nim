type
  Item* = object
    id: string
    alias: string
    identicon: string
    address: string
    keyUid: string

proc initItem*(id, alias, identicon, address, keyUid: string): Item =
  result.id = id
  result.alias = alias
  result.identicon = identicon
  result.address = address
  result.keyUid = keyUid

proc getId*(self: Item): string =
  return self.id

proc getAlias*(self: Item): string =
  return self.alias

proc getIdenticon*(self: Item): string =
  return self.identicon

proc getAddress*(self: Item): string =
  return self.address

proc getKeyUid*(self: Item): string =
  return self.keyUid
