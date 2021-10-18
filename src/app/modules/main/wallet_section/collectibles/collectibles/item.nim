import strformat

type 
  Item* = object
    id: int
    name, imageThumbnailUrl: string

proc initItem*(id: int, name: string, imageThumbnailUrl: string): Item =
  result.id = id
  result.name = name
  result.imageThumbnailUrl = imageThumbnailUrl

proc `$`*(self: Item): string =
  result = fmt"""Collectibles(
    id: {self.id}, 
    name: {self.name},
    imageThumbnailUrl: {self.imageThumbnailUrl}
    ]"""

proc getId*(self: Item): int = 
  return self.id

proc getName*(self: Item): string = 
  return self.name

proc getImageThumbnailUrl*(self: Item): string = 
  return self.imageThumbnailUrl