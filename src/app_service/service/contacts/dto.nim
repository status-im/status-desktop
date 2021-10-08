{.used.}

import json, strformat

include ../../common/json_utils

type
  ImagesDto* = ref object
    thumbnail*: string
    large*: string

type ContactDto* = ref object
  id*: string
  name*: string
  ensVerified*: bool
  alias: string
  identicon*: string
  lastUpdated*: int64
  image*: ImagesDto
  added*: bool
  blocked*: bool
  hasAddedUs*: bool
  isSyncing*: bool
  removed: bool

proc `$`(self: ImagesDto): string =
  result = fmt"""ImagesDto(
    thumbnail: {self.thumbnail},
    large: {self.large}, 
    ]"""

proc `$`*(self: ContactDto): string =
  result = fmt"""ContactDto(
    id: {self.id}, 
    name: {self.name}, 
    ensVerified: {self.ensVerified}, 
    alias: {self.alias}, 
    identicon: {self.identicon}, 
    lastUpdated: {self.lastUpdated}, 
    image:[
      {$self.image}
    ],
    added:{self.added}
    blocked:{self.blocked}
    hasAddedUs:{self.hasAddedUs}
    isSyncing:{self.isSyncing}
    removed:{self.removed}    
    )"""

proc toImagesDto(jsonObj: JsonNode): ImagesDto =
  result = ImagesDto()

  var largeObj: JsonNode
  if(jsonObj.getProp("large", largeObj)):
    discard jsonObj.getProp("uri", result.large)

  var thumbnailObj: JsonNode
  if(jsonObj.getProp("thumbnail", thumbnailObj)):
    discard jsonObj.getProp("uri", result.thumbnail)

proc toContactDto*(jsonObj: JsonNode): ContactDto =
  result = ContactDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("ensVerified", result.ensVerified)
  discard jsonObj.getProp("alias", result.alias)
  discard jsonObj.getProp("identicon", result.identicon)
  discard jsonObj.getProp("lastUpdated", result.lastUpdated)
  
  var imageObj: JsonNode
  if(jsonObj.getProp("images", imageObj)):
    result.image = toImagesDto(imageObj)
  
  discard jsonObj.getProp("added", result.added)
  discard jsonObj.getProp("blocked", result.blocked)
  discard jsonObj.getProp("hasAddedUs", result.hasAddedUs)
  discard jsonObj.getProp("IsSyncing", result.isSyncing)
  discard jsonObj.getProp("Removed", result.removed)