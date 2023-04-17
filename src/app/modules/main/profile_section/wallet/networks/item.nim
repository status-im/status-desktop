import strformat

type
  Item* = object
    chainId: int
    layer: int
    chainName: string
    iconUrl: string

proc initItem*(
  chainId: int,
  layer: int,
  chainName: string,
  iconUrl: string,
): Item =
  result.chainId = chainId
  result.layer = layer
  result.chainName = chainName
  result.iconUrl = iconUrl

proc `$`*(self: Item): string =
  result = fmt"""NetworkItem(
    chainId: {self.chainId},
    chainName: {self.chainName},
    layer: {self.layer},
    iconUrl:{self.iconUrl},
    ]"""

proc getChainId*(self: Item): int =
  return self.chainId

proc getLayer*(self: Item): int =
  return self.layer

proc getChainName*(self: Item): string =
  return self.chainName

proc getIconURL*(self: Item): string =
  return self.iconUrl