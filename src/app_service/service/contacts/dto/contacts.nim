{.used.}

import json, strformat, strutils

include ../../../common/json_utils
include ../../../common/utils

type
  Images* = object
    thumbnail*: string
    large*: string

type TrustStatus* {.pure.}= enum
  Unknown = 0,
  Trusted = 1,
  Untrustworthy = 2

type  VerificationStatus* {.pure.}= enum
  Unverified = 0
  Verifying = 1
  Verified = 2

type VerificationRequest* = object
  fromID*: string
  toID*: string
  challenge*: string
  requestedAt*: int64
  response*: string
  repliedAt*: int64
  status*: VerificationStatus

type ContactsDto* = object
  id*: string
  name*: string
  ensVerified*: bool
  displayName*: string
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
  trustStatus*: TrustStatus
  verificationStatus*: VerificationStatus

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
    displayName: {self.displayName},
    image:[
      {$self.image}
    ],
    added:{self.added},
    blocked:{self.blocked},
    hasAddedUs:{self.hasAddedUs},
    isSyncing:{self.isSyncing},
    removed:{self.removed},
    trustStatus:{self.trustStatus},
    verificationStatus:{self.verificationStatus},
    )"""

proc toImages(jsonObj: JsonNode): Images =
  result = Images()

  var largeObj: JsonNode
  if(jsonObj.getProp("large", largeObj)):
    discard largeObj.getProp("uri", result.large)

  var thumbnailObj: JsonNode
  if(jsonObj.getProp("thumbnail", thumbnailObj)):
    discard thumbnailObj.getProp("uri", result.thumbnail)

proc toTrustStatus*(value: int): TrustStatus =
  result = TrustStatus.Unknown
  if value >= ord(low(TrustStatus)) or value <= ord(high(TrustStatus)):
      result = TrustStatus(value)
  
proc toVerificationStatus*(value: int): VerificationStatus =
  result = VerificationStatus.Unverified
  if value >= ord(low(VerificationStatus)) or value <= ord(high(VerificationStatus)):
      result = VerificationStatus(value)
  
proc toVerificationRequest*(jsonObj: JsonNode): VerificationRequest =
  result = VerificationRequest()
  discard jsonObj.getProp("from", result.fromID)
  discard jsonObj.getProp("to", result.toID)
  discard jsonObj.getProp("challenge", result.challenge)
  discard jsonObj.getProp("response", result.response)
  discard jsonObj.getProp("requested_at", result.requestedAt)
  discard jsonObj.getProp("replied_at", result.repliedAt)
  var verificationStatusInt: int
  discard jsonObj.getProp("verification_status", verificationStatusInt)
  result.status = verificationStatusInt.toVerificationStatus()

proc toContactsDto*(jsonObj: JsonNode): ContactsDto =
  result = ContactsDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("ensVerified", result.ensVerified)
  discard jsonObj.getProp("displayName", result.displayName)
  discard jsonObj.getProp("alias", result.alias)
  discard jsonObj.getProp("identicon", result.identicon)
  discard jsonObj.getProp("lastUpdated", result.lastUpdated)
  discard jsonObj.getProp("lastUpdatedLocally", result.lastUpdatedLocally)
  discard jsonObj.getProp("localNickname", result.localNickname)
  
  result.trustStatus = TrustStatus.Unknown
  var trustStatusInt: int
  discard jsonObj.getProp("trustStatus", trustStatusInt)
  result.trustStatus = trustStatusInt.toTrustStatus()
  
  var verificationStatusInt: int
  discard jsonObj.getProp("verificationStatus", verificationStatusInt)
  result.verificationStatus = verificationStatusInt.toVerificationStatus()

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
  elif contact.displayName.len > 0:
    result = contact.displayName
  else:
    result = contact.alias

proc isContact*(self: ContactsDto): bool =
  result = self.added

proc isBlocked*(self: ContactsDto): bool =
  result = self.blocked

proc requestReceived*(self: ContactsDto): bool =
  result = self.hasAddedUs

proc trustStatus*(self: ContactsDto): TrustStatus =
  result = self.trustStatus
