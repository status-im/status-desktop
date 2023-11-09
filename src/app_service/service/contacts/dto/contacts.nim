{.used.}

import json, strformat, strutils
import ../../../common/social_links

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

type ContactRequestState* {.pure.} = enum
  None = 0
  Mutual = 1
  Sent = 2
  Received = 3
  Dismissed = 4

type VerificationStatus* {.pure.}= enum
  Unverified = 0
  Verifying = 1
  Verified = 2
  Declined = 3
  Canceled = 4
  Trusted = 5
  Untrustworthy = 6

type VerificationRequest* = object
  id*: string
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
  lastUpdated*: int64
  lastUpdatedLocally*: int64
  localNickname*: string
  bio*: string
  socialLinks*: SocialLinks
  image*: Images
  added*: bool
  blocked*: bool
  hasAddedUs*: bool
  isSyncing*: bool
  removed*: bool
  trustStatus*: TrustStatus
  contactRequestState*: ContactRequestState
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
    contactRequestState:{self.contactRequestState},
    verificationStatus:{self.verificationStatus},
    )"""

proc toImages(jsonObj: JsonNode): Images =
  result = Images()

  var largeObj: JsonNode
  if(jsonObj.getProp("large", largeObj)):
    discard largeObj.getProp("localUrl", result.large)

  var thumbnailObj: JsonNode
  if(jsonObj.getProp("thumbnail", thumbnailObj)):
    discard thumbnailObj.getProp("localUrl", result.thumbnail)

proc toContactRequestState*(value: int): ContactRequestState =
  result = ContactRequestState.None
  if value >= ord(low(ContactRequestState)) or value <= ord(high(ContactRequestState)):
      result = ContactRequestState(value)

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
  discard jsonObj.getProp("id", result.id)
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
  discard jsonObj.getProp("ensVerified", result.ensVerified)
  result.name = ""
  if (result.ensVerified):
    discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("displayName", result.displayName)
  discard jsonObj.getProp("alias", result.alias)
  discard jsonObj.getProp("lastUpdated", result.lastUpdated)
  discard jsonObj.getProp("lastUpdatedLocally", result.lastUpdatedLocally)
  discard jsonObj.getProp("localNickname", result.localNickname)
  discard jsonObj.getProp("bio", result.bio)

  result.contactRequestState = ContactRequestState.None
  var contactRequestState: int
  discard jsonObj.getProp("contactRequestState", contactRequestState)
  result.contactRequestState = contactRequestState.toContactRequestState()

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

  var socialLinksObj: JsonNode
  if(jsonObj.getProp("socialLinks", socialLinksObj)):
    result.socialLinks = toSocialLinks(socialLinksObj)

  discard jsonObj.getProp("added", result.added)
  discard jsonObj.getProp("blocked", result.blocked)
  discard jsonObj.getProp("hasAddedUs", result.hasAddedUs)
  discard jsonObj.getProp("IsSyncing", result.isSyncing)
  discard jsonObj.getProp("Removed", result.removed)

proc userExtractedName(contact: ContactsDto): string =
  if(contact.name.len > 0 and contact.ensVerified):
    result = contact.name
  elif contact.displayName.len > 0:
    result = contact.displayName
  else:
    result = contact.alias

proc userDefaultDisplayName*(contact: ContactsDto): string =
  if(contact.localNickname.len > 0):
    result = contact.localNickname
  else:
    result = userExtractedName(contact)

proc userOptionalName*(contact: ContactsDto): string =
  if(contact.localNickname.len > 0):
    result = userExtractedName(contact)

proc isContactRequestReceived*(self: ContactsDto): bool =
  return self.hasAddedUs

proc isReceivedContactRequestRejected*(self: ContactsDto): bool =
  return self.contactRequestState == ContactRequestState.Dismissed

proc isContactRequestSent*(self: ContactsDto): bool =
  return self.added

proc isContactRemoved*(self: ContactsDto): bool =
  return self.removed

# Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
# proc isSentContactRequestRejected*(self: ContactsDto): bool =
#   # TODO not implemented in `status-go` yet
#   # We don't have this prop for now.
#   return false

proc isBlocked*(self: ContactsDto): bool =
  return self.blocked

proc isContact*(self: ContactsDto): bool =
  # TODO not implemented in `status-go` yet
  # But for now we consider that contact is mutual contact if I added him and he added me.
  return self.hasAddedUs and self.added and not self.removed and not self.blocked

proc trustStatus*(self: ContactsDto): TrustStatus =
  result = self.trustStatus

proc isContactVerified*(self: ContactsDto): bool =
  return self.verificationStatus == VerificationStatus.Verified

proc isContactUntrustworthy*(self: ContactsDto): bool =
  return self.trustStatus == TrustStatus.Untrustworthy

proc isContactMarked*(self: ContactsDto): bool =
  return self.isContactVerified() or self.isContactUntrustworthy()
