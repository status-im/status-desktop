import NimQml

import sequtils, sugar
import ../../shared_models/[color_hash_item, color_hash_model]

type
  Item* = object
    name: string
    thumbnailImage: string
    largeImage: string
    keyUid: string
    colorHash: color_hash_model.Model
    colorHashVariant: QVariant
    colorId: int

proc initItem*(name, thumbnailImage, largeImage, keyUid: string, colorHash: seq[ColorHashSegment], colorId: int):
  Item =
  result.name = name
  result.thumbnailImage = thumbnailImage
  result.largeImage = largeImage
  result.keyUid = keyUid
  result.colorHash = color_hash_model.newModel()
  result.colorHash.setItems(map(colorHash, x => color_hash_item.initItem(x.len, x.colorIdx)))
  result.colorHashVariant = newQVariant(result.colorHash)
  result.colorId = colorId

proc getName*(self: Item): string =
  return self.name

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
