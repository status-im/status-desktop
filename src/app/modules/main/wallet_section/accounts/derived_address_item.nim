import strformat

type
  DerivedAddressItem* = object
    address: string
    path: string
    hasActivity: bool

proc initDerivedAddressItem*(
  address: string,
  path: string,
  hasActivity: bool
): DerivedAddressItem =
  result.address = address
  result.path = path
  result.hasActivity = hasActivity

proc `$`*(self: DerivedAddressItem): string =
  result = fmt"""DerivedAddressItem(
    address: {self.address},
    path: {self.path},
    hasActivity: {self.hasActivity}
    ]"""

proc getAddress*(self: DerivedAddressItem): string =
  return self.address

proc getPath*(self: DerivedAddressItem): string =
  return self.path

proc getHasActivity*(self: DerivedAddressItem): bool =
  return self.hasActivity

