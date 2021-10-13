{.used.}

import json, strformat

include ../../common/json_utils

type Dto* = ref object
  username*: string
  identicon*: string
  largeImage*: string
  thumbnailImage*: string
  hasIdentityImage*: bool
  messagesFromContactsOnly*: bool

proc `$`*(self: Dto): string =
  result = fmt"""ProfileDto(
    username: {self.username},
    identicon: {self.identicon},
    largeImage: {self.largeImage},
    thumbnailImage: {self.thumbnailImage},
    hasIdentityImage: {self.hasIdentityImage},
    messagesFromContactsOnly: {self.messagesFromContactsOnly}
    )"""

proc toDto*(jsonObj: JsonNode): Dto =
  result = Dto()

  discard jsonObj.getProp("username", result.username)
  discard jsonObj.getProp("identicon", result.identicon)
  discard jsonObj.getProp("largeImage", result.largeImage)
  discard jsonObj.getProp("thumbnailImage", result.thumbnailImage)
  discard jsonObj.getProp("hasIdentityImage", result.hasIdentityImage)
  discard jsonObj.getProp("messagesFromContactsOnly", result.messagesFromContactsOnly)
