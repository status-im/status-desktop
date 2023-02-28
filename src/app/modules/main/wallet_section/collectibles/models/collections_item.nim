import strformat, stint
import ./collectibles_model as collectibles_model
import ./collectibles_item as collectibles_item

type
  Item* = object
    name: string
    slug: string
    imageUrl: string
    ownedAssetCount: Uint256
    collectiblesLoaded*: bool
    collectiblesModel: collectibles_model.Model

proc initItem*(name, slug, imageUrl: string, ownedAssetCount: Uint256, collectiblesLoaded: bool, collectibles: seq[collectibles_item.Item]): Item =
  result.name = name
  result.slug = slug
  result.imageUrl = imageUrl
  result.ownedAssetCount = ownedAssetCount
  result.collectiblesLoaded = collectiblesLoaded
  result.collectiblesModel = collectibles_model.newModel(collectibles)

proc initItem*(): Item =
  result = initItem("", "", "", u256(0), false, @[])

proc `$`*(self: Item): string =
  result = fmt"""CollectibleCollection(
    name: {self.name},
    slug: {self.slug},
    imageUrl: {self.imageUrl},
    ownedAssetCount: {self.ownedAssetCount},
    collectiblesLoaded: {self.collectiblesLoaded},
    collectibles: {self.collectiblesModel}
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getSlug*(self: Item): string =
  return self.slug

proc getImageUrl*(self: Item): string =
  return self.imageUrl

proc getOwnedAssetCount*(self: Item): Uint256 =
  return self.ownedAssetCount

proc getCollectiblesLoaded*(self: Item): bool =
  return self.collectiblesLoaded

proc getCollectiblesModel*(self: Item): collectibles_model.Model =
  return self.collectiblesModel
