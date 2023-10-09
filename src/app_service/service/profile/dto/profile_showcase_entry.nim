import json, strformat, strutils, stint, json_serialization
include ../../../common/json_utils
include ../../../common/utils

type ProfileShowcaseEntryType* {.pure.}= enum
  TypeCommunity = 0,
  TypeAccount = 1,
  TypeCollectible = 2,
  TypeAsset = 3,

type ProfileShowcaseVisibility* {.pure.}= enum
  NoOne = 0,
  IDVerifiedContacts = 1,
  Contacts = 2,
  Everyone = 3,

type ProfileShowcaseEntryDto* = ref object of RootObj
  id*: string
  entryType*: ProfileShowcaseEntryType
  visibility*: ProfileShowcaseVisibility
  order*: int

proc `$`*(self: ProfileShowcaseEntryDto): string =
  result = fmt"""ProfileShowcaseEntryDto(
    id: {$self.id},
    entryType: {self.entryType},
    visibility: {self.visibility},
    order: {self.order}
    )"""

proc toProfileShowcaseEntryDto*(jsonObj: JsonNode): ProfileShowcaseEntryDto =
  result = ProfileShowcaseEntryDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("order", result.order)

  var entryTypeInt: int
  if (jsonObj.getProp("type", entryTypeInt) and
    (entryTypeInt >= ord(low(ProfileShowcaseEntryType)) and
    entryTypeInt <= ord(high(ProfileShowcaseEntryType)))):
      result.entryType = ProfileShowcaseEntryType(entryTypeInt)

  var visibilityInt: int
  if (jsonObj.getProp("contactVerificationStatus", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.visibility = ProfileShowcaseVisibility(visibilityInt)
