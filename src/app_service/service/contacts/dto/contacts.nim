{.used.}

import json, strformat, strutils

include ../../../common/json_utils
include ../../../common/utils

type
  Images* = object
    thumbnail*: string
    large*: string

type ContactsDto* = object
  id*: string
  name*: string
  ensVerified*: bool
  alias*: string
  identicon*: string
  lastUpdated*: int64
  lastUpdatedLocally*: int64
  localNickname*: string
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
    lastUpdatedLocally: {self.lastUpdatedLocally},
    localNickname: {self.localNickname},
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
  discard jsonObj.getProp("lastUpdatedLocally", result.lastUpdatedLocally)
  discard jsonObj.getProp("localNickname", result.localNickname)

  var imageObj: JsonNode
  if(jsonObj.getProp("images", imageObj)):
    result.image = toImages(imageObj)

  discard jsonObj.getProp("added", result.added)
  discard jsonObj.getProp("blocked", result.blocked)
  discard jsonObj.getProp("hasAddedUs", result.hasAddedUs)
  discard jsonObj.getProp("IsSyncing", result.isSyncing)
  discard jsonObj.getProp("Removed", result.removed)

proc userNameOrAlias*(contact: ContactsDto): string =
  if(contact.localNickname.len > 0):
    result = contact.localNickname
  elif(contact.name.len > 0 and contact.ensVerified):
    result = prettyEnsName(contact.name)
  else:
    result = contact.alias

proc isContact*(self: ContactsDto): bool =
  result = self.added

proc isBlocked*(self: ContactsDto): bool =
  result = self.blocked

proc requestReceived*(self: ContactsDto): bool =
  result = self.hasAddedUs
