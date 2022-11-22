import strformat

type
  Trait* = object
    traitType, value, displayType, maxValue: string

proc getTraitType*(self: Trait): string =
  return self.traitType

proc getValue*(self: Trait): string =
  return self.value

proc getDisplayType*(self: Trait): string =
  return self.displayType

proc getMaxValue*(self: Trait): string =
  return self.maxValue

proc initTrait*(
  traitType, value, displayType, maxValue: string
): Trait =
  result.traitType = traitType
  result.value = value
  result.displayType = displayType
  result.maxValue = maxValue

type
  Item* = object
    id: int
    name: string
    imageUrl: string
    backgroundColor: string
    description: string
    permalink: string
    properties: seq[Trait]
    rankings: seq[Trait]
    stats: seq[Trait]

proc initItem*(
  id: int,
  name: string,
  imageUrl: string,
  backgroundColor: string,
  description: string,
  permalink: string,
  properties: seq[Trait],
  rankings: seq[Trait],
  stats: seq[Trait]
): Item =
  result.id = id
  result.name = name
  result.imageUrl = imageUrl
  result.backgroundColor = if (backgroundColor == ""): "transparent" else: ("#" & backgroundColor)
  result.description = description
  result.permalink = permalink
  result.properties = properties
  result.rankings = rankings
  result.stats = stats

proc initItem*: Item =
  result = initItem(-1, "", "", "transparent", "Collectibles", "", @[], @[], @[])

proc `$`*(self: Item): string =
  result = fmt"""Collectibles(
    id: {self.id},
    name: {self.name},
    imageUrl: {self.imageUrl},
    backgroundColor: {self.backgroundColor},
    description: {self.description},
    permalink: {self.permalink},
    ]"""

proc getId*(self: Item): int =
  return self.id

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

proc getProperties*(self: Item): seq[Trait] =
  return self.properties

proc getRankings*(self: Item): seq[Trait] =
  return self.rankings

proc getStats*(self: Item): seq[Trait] =
  return self.stats
