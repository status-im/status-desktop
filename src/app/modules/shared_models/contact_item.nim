import Tables, json

type
  ImageItem* = object
    thumbnail*: string
    large*: string

proc initImageItem*(
  thumbnail: string,
  large: string
  ): ImageItem =
  result = ImageItem()
  result.thumbnail = thumbnail
  result.large = large

proc thumbnail*(self: ImageItem): string {.inline.} = 
  self.thumbnail

proc large*(self: ImageItem): string {.inline.} = 
  self.large

type 
  Item* = ref object
    id: string
    name: string
    ensVerified: bool
    alias: string
    identicon: string
    lastUpdated: int64
    lastUpdatedLocally: int64
    localNickname: string
    image: ImageItem 
    added: bool
    blocked: bool
    isSyncing: bool
    hasAddedUs: bool
    removed: bool

proc initItem*(
  id: string,
  name: string,
  ensVerified: bool,
  alias: string,
  identicon: string,
  lastUpdated: int64,
  lastUpdatedLocally: int64,
  image: ImageItem,
  added: bool,
  blocked: bool,
  isSyncing: bool,
  hasAddedUs: bool,
  removed: bool
  ): Item =
  result = Item()
  result.id = id
  result.name = name
  result.ensVerified = ensVerified
  result.alias = alias
  result.lastUpdated = lastUpdated
  result.lastUpdatedLocally = lastUpdatedLocally
  result.image = image
  result.added = added
  result.blocked = blocked
  result.isSyncing = isSyncing
  result.hasAddedUs = hasAddedUs
  result.removed = removed

proc id*(self: Item): string {.inline.} = 
  self.id

proc name*(self: Item): string {.inline.} = 
  self.name

proc ensVerified*(self: Item): bool {.inline.} = 
  self.ensVerified

proc alias*(self: Item): string {.inline.} = 
  self.alias

proc lastUpdated*(self: Item): int64 {.inline.} = 
  self.lastUpdated

proc lastUpdatedLocally*(self: Item): int64 {.inline.} = 
  self.lastUpdatedLocally

proc image*(self: Item): ImageItem {.inline.} = 
  self.image

proc added*(self: Item): bool {.inline.} = 
  self.added

proc blocked*(self: Item): bool {.inline.} = 
  self.blocked

proc isSyncing*(self: Item): bool {.inline.} = 
  self.isSyncing

proc hasAddedUs*(self: Item): bool {.inline.} = 
  self.hasAddedUs

proc removed*(self: Item): bool {.inline.} = 
  self.removed
