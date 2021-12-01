import strformat, stint

#####
# Sticker Item
#####
type
  Item* = object
    hash: string
    packId: int

proc initItem*(
  hash: string,
  packId: int
): Item =
  result.hash = hash
  result.packId = packId

proc `$`*(self: Item): string =
  result = fmt"""StickerItem(
    hash: {self.hash}, 
    packId: {$self.packId}
    ]"""

proc getHash*(self: Item): string = 
  return self.hash

proc getPackId*(self: Item): int = 
  return self.packId

#####
# Sticker Pack Item
#####
type
  PackItem* = object
    id*: int
    name*: string
    author*: string
    price*: Stuint[256]
    preview*: string
    stickers*: seq[Item]
    thumbnail*: string

proc initPackItem*(
  id: int,
  name: string,
  author: string,
  price: Stuint[256],
  preview: string,
  stickers: seq[Item],
  thumbnail: string
): PackItem =
  result.id = id
  result.name = name
  result.author = author
  result.price = price
  result.preview = preview
  result.stickers = stickers
  result.thumbnail = thumbnail

proc `$`*(self: PackItem): string =
  result = fmt"""StickerItem(
    id: {self.id}, 
    name: {$self.name},
    author: {$self.author},
    price: {$self.price},
    preview: {$self.preview},
    stickers: {$self.stickers},
    thumbnail: {$self.thumbnail},
    ]"""

proc getId*(self: PackItem): int = 
  return self.id

proc getName*(self: PackItem): string = 
  return self.name

proc getAuthor*(self: PackItem): string = 
  return self.author

proc getPrice*(self: PackItem): Stuint[256] = 
  return self.price

proc getPreview*(self: PackItem): string = 
  return self.preview

proc getThumbnail*(self: PackItem): string = 
  return self.thumbnail

proc getStickers*(self: PackItem): seq[Item] = 
  return self.stickers
