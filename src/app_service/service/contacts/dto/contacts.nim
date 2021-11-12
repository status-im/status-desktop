{.used.}

import json, strformat, strutils

include ../../../common/json_utils

const domain* = ".stateofus.eth"

type
  Images* = ref object
    thumbnail*: string
    large*: string

type ContactsDto* = ref object
  id*: string
  name*: string
  ensVerified*: bool
  alias*: string
  identicon*: string
  lastUpdated*: int64
  image*: Images
  added*: bool
  blocked*: bool
  hasAddedUs*: bool
  isSyncing*: bool
  removed*: bool

proc `$`(self: Images): string =
  result = fmt"""Images(
    thumbnail: {self.thumbnail},
    large: {self.large}, 
    ]"""

proc `$`*(self: ContactsDto): string =
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

proc toImages(jsonObj: JsonNode): Images =
  result = Images()

  var largeObj: JsonNode
  if(jsonObj.getProp("large", largeObj)):
    discard largeObj.getProp("uri", result.large)

  var thumbnailObj: JsonNode
  if(jsonObj.getProp("thumbnail", thumbnailObj)):
    discard thumbnailObj.getProp("uri", result.thumbnail)

proc toContactsDto*(jsonObj: JsonNode): ContactsDto =
  result = ContactsDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("ensVerified", result.ensVerified)
  discard jsonObj.getProp("alias", result.alias)
  discard jsonObj.getProp("identicon", result.identicon)
  discard jsonObj.getProp("lastUpdated", result.lastUpdated)
  
  var imageObj: JsonNode
  if(jsonObj.getProp("images", imageObj)):
    result.image = toImages(imageObj)
  
  discard jsonObj.getProp("added", result.added)
  discard jsonObj.getProp("blocked", result.blocked)
  discard jsonObj.getProp("hasAddedUs", result.hasAddedUs)
  discard jsonObj.getProp("IsSyncing", result.isSyncing)
  discard jsonObj.getProp("Removed", result.removed)

proc userName*(ensName: string, removeSuffix: bool = false): string =
  if ensName != "" and ensName.endsWith(domain):
    if removeSuffix:
      result = ensName.split(".")[0]
    else:
      result = ensName
  else:
    if ensName.endsWith(".eth") and removeSuffix:
      return ensName.split(".")[0]
    result = ensName

proc userNameOrAlias*(contact: ContactsDto, removeSuffix: bool = false): string =
  if(contact.name != "" and contact.ensVerified):
    result = "@" & userName(contact.name, removeSuffix)
  else:
    result = contact.alias

proc isContact*(self: ContactsDto): bool =
  result = self.added

proc isBlocked*(self: ContactsDto): bool =
  result = self.blocked

proc requestReceived*(self: ContactsDto): bool =
  result = self.hasAddedUs