type
  Item* = object
    id: string
    alias: string
    address: string
    pubKey: string
    keyUid: string

proc initItem*(id, alias, address, pubKey, keyUid: string): Item =
  result.id = id
  result.alias = alias
  result.address = address
  result.pubKey = pubKey
  result.keyUid = keyUid

proc getId*(self: Item): string =
  return self.id

proc getAlias*(self: Item): string =
  return self.alias

proc getAddress*(self: Item): string =
  return self.address

proc getPubKey*(self: Item): string =
  return self.pubKey

proc getKeyUid*(self: Item): string =
  return self.keyUid
