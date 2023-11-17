import strformat

type
  Item* = object
    id: string  # Collectible ID if isCollection=false, Collection Slug otherwise
    chainId: int
    name: string
    iconUrl: string
    collectionId: string
    collectionName: string
    isCollection: bool

proc initItem*(
  id: string,
  chainId: int,
  name: string,
  iconUrl: string,
  collectionId: string,
  collectionName: string,
  isCollection: bool
): Item =
  result.id = id
  result.chainId = chainId
  result.name = name
  result.iconUrl = iconUrl
  result.collectionId = collectionId
  result.collectionName = collectionName
  result.isCollection = isCollection

proc `$`*(self: Item): string =
  result = fmt"""CollectiblesNestedEntry(
    id: {self.id},
    chainId: {self.chainId},
    name: {self.name},
    iconUrl: {self.iconUrl},
    collectionId: {self.collectionId},
    collectionName: {self.collectionName},
    isCollection: {self.isCollection},
    ]"""

proc getId*(self: Item): string =
  return self.id

proc getChainId*(self: Item): int =
  return self.chainId

proc getName*(self: Item): string =
  return self.name

proc getIconUrl*(self: Item): string =
  return self.iconUrl

proc getCollectionId*(self: Item): string =
  return self.collectionId

proc getCollectionName*(self: Item): string =
  return self.collectionName

proc getIsCollection*(self: Item): bool =
  return self.isCollection
