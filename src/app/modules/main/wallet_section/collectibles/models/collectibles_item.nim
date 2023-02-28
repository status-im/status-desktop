import strformat, stint
import ./collectible_trait_item

type
  Item* = object
    id: int
    tokenId: UInt256
    name: string
    imageUrl: string
    backgroundColor: string
    description: string
    permalink: string
    properties: seq[CollectibleTrait]
    rankings: seq[CollectibleTrait]
    stats: seq[CollectibleTrait]

proc initItem*(
  id: int,
  tokenId: UInt256,
  name: string,
  imageUrl: string,
  backgroundColor: string,
  description: string,
  permalink: string,
  properties: seq[CollectibleTrait],
  rankings: seq[CollectibleTrait],
  stats: seq[CollectibleTrait]
): Item =
  result.id = id
  result.tokenId = tokenId
  result.name = name
  result.imageUrl = imageUrl
  result.backgroundColor = if (backgroundColor == ""): "transparent" else: ("#" & backgroundColor)
  result.description = description
  result.permalink = permalink
  result.properties = properties
  result.rankings = rankings
  result.stats = stats

proc initItem*: Item =
  result = initItem(-1, u256(0), "", "", "transparent", "Collectibles", "", @[], @[], @[])

proc `$`*(self: Item): string =
  result = fmt"""Collectibles(
    id: {self.id},
    tokenId: {self.tokenId},
    name: {self.name},
    imageUrl: {self.imageUrl},
    backgroundColor: {self.backgroundColor},
    description: {self.description},
    permalink: {self.permalink},
    ]"""

proc getId*(self: Item): int =
  return self.id

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
