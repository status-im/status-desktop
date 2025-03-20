import NimQml

import sequtils, sugar
import ../../shared_models/[color_hash_item, color_hash_model]

type
  Item* = object
    order: int
    name: string
    icon: string
    thumbnailImage: string
    largeImage: string
    keyUid: string
    colorHash: color_hash_model.Model
    colorHashVariant: QVariant
    colorId: int
    keycardPairing: string

proc initItem*(order: int, name, icon, thumbnailImage, largeImage, keyUid: string, colorHash: seq[ColorHashSegment] = @[], 
  colorId: int = -1, keycardPairing: string = ""):
  Item =
  result.order = order
  result.name = name
  result.icon = icon
  result.thumbnailImage = thumbnailImage
  result.largeImage = largeImage
  result.keyUid = keyUid
  result.colorHash = color_hash_model.newModel()
  result.colorHash.setItems(map(colorHash, x => color_hash_item.initItem(x.len, x.colorIdx)))
  result.colorHashVariant = newQVariant(result.colorHash)
  result.colorId = colorId
  result.keycardPairing = keycardPairing

proc getOrder*(self: Item): int =
  return self.order

proc getName*(self: Item): string =
  return self.name

proc getIcon*(self: Item): string =
  return self.icon

proc getThumbnailImage*(self: Item): string =
  return self.thumbnailImage

proc getLargeImage*(self: Item): string =
  return self.largeImage

proc getKeyUid*(self: Item): string =
  return self.keyUid

proc getColorHash*(self: Item): color_hash_model.Model =
  return self.colorHash

proc getColorHashVariant*(self: Item): QVariant =
  return self.colorHashVariant

proc getColorId*(self: Item): int =
  return self.colorId

proc getKeycardPairing*(self: Item): string =
  return self.keycardPairing

proc getKeycardCreatedAccount*(self: Item): bool =
  return self.keycardPairing.len > 0