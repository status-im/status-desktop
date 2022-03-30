type
  Item* = object
    name: string
    thumbnailImage: string
    largeImage: string
    keyUid: string

proc initItem*(name, thumbnailImage, largeImage, keyUid: string):
  Item =
  result.name = name
  result.thumbnailImage = thumbnailImage
  result.largeImage = largeImage
  result.keyUid = keyUid

proc getName*(self: Item): string =
  return self.name

proc getThumbnailImage*(self: Item): string =
    result = self.thumbnailImage

proc getLargeImage*(self: Item): string =
    result = self.largeImage

proc getKeyUid*(self: Item): string =
  return self.keyUid
