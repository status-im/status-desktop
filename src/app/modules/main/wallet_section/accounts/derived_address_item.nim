import strformat

type
  DerivedAddressItem* = object
    address: string
    path: string
    hasActivity: bool
    alreadyCreated: bool

proc initDerivedAddressItem*(
  address: string,
  path: string,
  hasActivity: bool,
  alreadyCreated: bool
): DerivedAddressItem =
  result.address = address
  result.path = path
  result.hasActivity = hasActivity
  result.alreadyCreated = alreadyCreated

proc `$`*(self: DerivedAddressItem): string =
  result = fmt"""DerivedAddressItem(
    address: {self.address},
    path: {self.path},
    hasActivity: {self.hasActivity}
    alreadyCreated: {self.alreadyCreated}
    ]"""

proc getAddress*(self: DerivedAddressItem): string =
  return self.address

proc getPath*(self: DerivedAddressItem): string =
  return self.path

proc getHasActivity*(self: DerivedAddressItem): bool =
  return self.hasActivity

proc getAlreadyCreated*(self: DerivedAddressItem): bool =
  return self.alreadyCreated


