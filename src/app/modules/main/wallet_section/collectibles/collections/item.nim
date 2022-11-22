import strformat

type
  Item* = object
    name: string
    slug: string
    imageUrl: string
    ownedAssetCount: int

proc initItem*(name, slug, imageUrl: string, ownedAssetCount: int): Item =
  result.name = name
  result.slug = slug
  result.imageUrl = imageUrl
  result.ownedAssetCount = ownedAssetCount

proc initItem*(): Item =
  result = initItem("", "", "", 0)

proc `$`*(self: Item): string =
  result = fmt"""CollectibleCollection(
    name: {self.name},
    slug: {self.slug},
    imageUrl: {self.imageUrl},
    ownedAssetCount: {self.ownedAssetCount}
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getSlug*(self: Item): string =
  return self.slug

proc getImageUrl*(self: Item): string =
  return self.imageUrl

proc getOwnedAssetCount*(self: Item): int =
  return self.ownedAssetCount

