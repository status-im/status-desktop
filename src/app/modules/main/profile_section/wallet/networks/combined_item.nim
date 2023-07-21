import strformat

import ./item

type
  CombinedItem* = object
    prod: Item
    test: Item
    layer: int

proc initCombinedItem*(
  prod: Item,
  test: Item,
  layer: int
): CombinedItem =
  result.prod = prod
  result.test = test
  result.layer = layer

proc `$`*(self: CombinedItem): string =
  result = fmt"""CombinedItem(
    prod: {self.prod},
    test: {self.test},
    layer: {self.layer},
    ]"""

proc getProd*(self: CombinedItem): Item =
  return self.prod

proc getTest*(self: CombinedItem): Item =
  return self.test

proc getLayer*(self: CombinedItem): int =
  return self.layer

proc getShortName*(self: CombinedItem, areTestNetworksEnabled: bool): string =
  if areTestNetworksEnabled:
    return self.test.shortName()
  else:
    return self.prod.shortName()

proc getChainId*(self: CombinedItem, areTestNetworksEnabled: bool): int =
  if areTestNetworksEnabled:
    return self.test.chainId()
  else:
    return self.prod.chainId()
