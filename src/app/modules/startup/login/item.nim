type 
  Item* = object
    name: string
    identicon: string
    thumbnailImage: string
    largeImage: string
    keyUid: string

proc initItem*(name, identicon, thumbnailImage, largeImage, keyUid: string):
  Item =
  result.name = name
  result.identicon = identicon
  result.thumbnailImage = thumbnailImage
  result.largeImage = largeImage
  result.keyUid = keyUid

proc getName*(self: Item): string = 
  return self.name

proc getIdenticon*(self: Item): string = 
  return self.identicon

proc getThumbnailImage*(self: Item): string = 
    result = self.thumbnailImage

proc getLargeImage*(self: Item): string = 
    result = self.largeImage

proc getKeyUid*(self: Item): string = 
  return self.keyUid