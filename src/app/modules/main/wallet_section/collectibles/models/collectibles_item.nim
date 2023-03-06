import strformat, stint
import ./collectible_trait_item

type
  Item* = object
    id: int
    address: string
    tokenId: UInt256
    name: string
    imageUrl: string
    backgroundColor: string
    description: string
    permalink: string
    properties: seq[CollectibleTrait]
    rankings: seq[CollectibleTrait]
    stats: seq[CollectibleTrait]
    collectionName: string
    collectionSlug: string
    collectionImageUrl: string
    isLoading: bool

proc initItem*(
  id: int,
  address: string,
  tokenId: UInt256,
  name: string,
  imageUrl: string,
  backgroundColor: string,
  description: string,
  permalink: string,
  properties: seq[CollectibleTrait],
  rankings: seq[CollectibleTrait],
  stats: seq[CollectibleTrait],
  collectionName: string,
  collectionSlug: string,
  collectionImageUrl: string
): Item =
  result.id = id
  result.address = address
  result.tokenId = tokenId
  result.name = if (name != ""): name else: ("#" & tokenId.toString())
  result.imageUrl = imageUrl
  result.backgroundColor = if (backgroundColor == ""): "transparent" else: ("#" & backgroundColor)
  result.description = description
  result.permalink = permalink
  result.properties = properties
  result.rankings = rankings
  result.stats = stats
  result.collectionName = collectionName
  result.collectionSlug = collectionSlug
  result.collectionImageUrl = collectionImageUrl
  result.isLoading = false

proc initItem*: Item =
  result = initItem(-1, "", u256(0), "", "", "transparent", "Collectibles", "", @[], @[], @[], "", "", "")

proc initLoadingItem*: Item =
  result = initItem()
  result.isLoading = true

proc `$`*(self: Item): string =
  result = fmt"""Collectibles(
    id: {self.id},
    address: {self.address},
    tokenId: {self.tokenId},
    name: {self.name},
    imageUrl: {self.imageUrl},
    backgroundColor: {self.backgroundColor},
    description: {self.description},
    permalink: {self.permalink},
    collectionName: {self.collectionName},
    collectionSlug: {self.collectionSlug},
    collectionImageUrl: {self.collectionImageUrl},
    ]"""

proc getId*(self: Item): int =
  return self.id

proc getAddress*(self: Item): string =
  return self.address

proc getTokenId*(self: Item): UInt256 =
  return self.tokenId

proc getName*(self: Item): string =
  return self.name

proc getImageUrl*(self: Item): string =
  return self.imageUrl

proc getBackgroundColor*(self: Item): string =
  return self.backgroundColor

proc getDescription*(self: Item): string =
  return self.description

proc getPermalink*(self: Item): string =
  return self.permalink

proc getProperties*(self: Item): seq[CollectibleTrait] =
  return self.properties

proc getRankings*(self: Item): seq[CollectibleTrait] =
  return self.rankings

proc getStats*(self: Item): seq[CollectibleTrait] =
  return self.stats

proc getCollectionName*(self: Item): string =
  return self.collectionName

proc getCollectionSlug*(self: Item): string =
  return self.collectionSlug

proc getCollectionImageUrl*(self: Item): string =
  return self.collectionImageUrl

proc getIsLoading*(self: Item): bool =
  return self.isLoading
